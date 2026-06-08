package config

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"sync"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/db"
)

// NotifyChannel is the Postgres NOTIFY channel that fires on every
// config_entries write (the trigger installed in migration 00008, plus the
// setConfigEntry / deleteConfigEntry resolvers). Overlay.Listen subscribes here.
const NotifyChannel = "config_changed"

// Overlay is the in-memory cache of config_entries (the DB-side overrides),
// loaded on startup and refreshed on every NOTIFY "config_changed" carrying the
// changed key as payload. Safe for concurrent use; consumers of hot keys read
// through the typed *Or helpers, which fall back to the supplied base
// (env/file/defaults boot value) when no override is set.
//
// A nil *Overlay is valid: every Lookup returns (nil,false) so the *Or helpers
// fall through to the caller's fallback. This lets tests and overlay-disabled
// boots call the helpers unconditionally.
type Overlay struct {
	pool   *pgxpool.Pool
	logger *slog.Logger

	mu      sync.RWMutex
	entries map[string]json.RawMessage

	onChange []func(key string)

	listenCancel context.CancelFunc
	listenDone   chan struct{}
}

// NewOverlay constructs an empty Overlay. Call Load before serving, then Listen.
func NewOverlay(pool *pgxpool.Pool, logger *slog.Logger) *Overlay {
	if logger == nil {
		logger = slog.Default()
	}
	return &Overlay{
		pool:    pool,
		logger:  logger,
		entries: map[string]json.RawMessage{},
	}
}

// OnChange registers a callback fired (with the changed key) after a live
// LISTEN/NOTIFY refresh. Use for apply-on-change values that aren't read through
// the *Or helpers per-use — e.g. the log level (a slog.LevelVar) or a schedule
// that must be re-registered. Callbacks run on the listener goroutine, so keep
// them quick and non-blocking. Not fired during the initial Load.
func (o *Overlay) OnChange(fn func(key string)) {
	o.mu.Lock()
	o.onChange = append(o.onChange, fn)
	o.mu.Unlock()
}

func (o *Overlay) fireChange(key string) {
	o.mu.RLock()
	cbs := make([]func(string), len(o.onChange))
	copy(cbs, o.onChange)
	o.mu.RUnlock()
	for _, fn := range cbs {
		fn(key)
	}
}

// Load replaces the cache with every row currently in config_entries.
func (o *Overlay) Load(ctx context.Context) error {
	rows, err := db.New(o.pool).ListConfigEntries(ctx)
	if err != nil {
		return fmt.Errorf("config overlay: list: %w", err)
	}
	next := make(map[string]json.RawMessage, len(rows))
	for _, r := range rows {
		next[r.Key] = append(json.RawMessage(nil), r.Value...)
	}
	o.mu.Lock()
	o.entries = next
	o.mu.Unlock()
	return nil
}

// Refresh re-reads a single key. If the row is absent the key is dropped from
// the cache (covers DELETE notifications too).
func (o *Overlay) Refresh(ctx context.Context, key string) error {
	row, err := db.New(o.pool).GetConfigEntry(ctx, key)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			o.mu.Lock()
			delete(o.entries, key)
			o.mu.Unlock()
			return nil
		}
		return fmt.Errorf("config overlay: get %q: %w", key, err)
	}
	value := append(json.RawMessage(nil), row.Value...)
	o.mu.Lock()
	o.entries[key] = value
	o.mu.Unlock()
	return nil
}

// Listen starts a background goroutine that LISTENs on NotifyChannel and calls
// Refresh for the payload key on each notification. It returns once the initial
// LISTEN has succeeded so callers can rely on subsequent NOTIFYs being received.
func (o *Overlay) Listen(ctx context.Context) error {
	listenCtx, cancel := context.WithCancel(ctx)
	o.listenCancel = cancel
	o.listenDone = make(chan struct{})

	ready := make(chan error, 1)
	go o.listenLoop(listenCtx, ready)

	select {
	case err := <-ready:
		if err != nil {
			cancel()
			return err
		}
		return nil
	case <-time.After(10 * time.Second):
		cancel()
		return fmt.Errorf("config overlay: LISTEN setup timed out")
	}
}

// Stop halts the listener goroutine and waits for it to exit.
func (o *Overlay) Stop() {
	if o.listenCancel != nil {
		o.listenCancel()
	}
	if o.listenDone != nil {
		<-o.listenDone
	}
}

func (o *Overlay) listenLoop(ctx context.Context, ready chan<- error) {
	defer close(o.listenDone)
	first := true
	for {
		err := o.listenOnce(ctx, func() {
			if first {
				first = false
				ready <- nil
			}
		})
		if err != nil {
			if errors.Is(ctx.Err(), context.Canceled) {
				if first {
					ready <- ctx.Err()
				}
				return
			}
			if first {
				first = false
				ready <- err
				return
			}
			o.logger.Warn("config overlay: listener disconnected, retrying", "error", err)
			select {
			case <-ctx.Done():
				return
			case <-time.After(1 * time.Second):
			}
			continue
		}
		return
	}
}

func (o *Overlay) listenOnce(ctx context.Context, onReady func()) error {
	conn, err := o.pool.Acquire(ctx)
	if err != nil {
		return fmt.Errorf("acquire conn: %w", err)
	}
	defer conn.Release()

	if _, err := conn.Exec(ctx, "LISTEN "+NotifyChannel); err != nil {
		return fmt.Errorf("LISTEN: %w", err)
	}
	onReady()

	for {
		notif, err := conn.Conn().WaitForNotification(ctx)
		if err != nil {
			return err
		}
		key := notif.Payload
		if key == "" {
			if err := o.Load(ctx); err != nil {
				o.logger.Warn("config overlay: full reload after empty NOTIFY failed", "error", err)
			}
			continue
		}
		if err := o.Refresh(ctx, key); err != nil {
			o.logger.Warn("config overlay: refresh after NOTIFY failed", "key", key, "error", err)
			continue
		}
		o.logger.Debug("config overlay: key refreshed via LISTEN/NOTIFY", "key", key)
		o.fireChange(key)
	}
}

// Lookup returns the raw JSON value for a key, or false if no override exists.
// The returned bytes are a copy. A nil receiver always returns (nil, false).
func (o *Overlay) Lookup(key string) (json.RawMessage, bool) {
	if o == nil {
		return nil, false
	}
	o.mu.RLock()
	defer o.mu.RUnlock()
	raw, ok := o.entries[key]
	if !ok {
		return nil, false
	}
	out := make(json.RawMessage, len(raw))
	copy(out, raw)
	return out, true
}

// StringOr returns the overlay value for key as a JSON string, else fallback.
func (o *Overlay) StringOr(key, fallback string) string {
	raw, ok := o.Lookup(key)
	if !ok {
		return fallback
	}
	var v string
	if err := json.Unmarshal(raw, &v); err != nil {
		o.warn(key, "string", err)
		return fallback
	}
	return v
}

// BoolOr returns the overlay value for key as a JSON bool, else fallback.
func (o *Overlay) BoolOr(key string, fallback bool) bool {
	raw, ok := o.Lookup(key)
	if !ok {
		return fallback
	}
	var v bool
	if err := json.Unmarshal(raw, &v); err != nil {
		o.warn(key, "bool", err)
		return fallback
	}
	return v
}

// IntOr returns the overlay value for key as a JSON number coerced to int, else fallback.
func (o *Overlay) IntOr(key string, fallback int) int {
	raw, ok := o.Lookup(key)
	if !ok {
		return fallback
	}
	var v int
	if err := json.Unmarshal(raw, &v); err != nil {
		o.warn(key, "int", err)
		return fallback
	}
	return v
}

// Float64Or returns the overlay value for key as a JSON number, else fallback.
func (o *Overlay) Float64Or(key string, fallback float64) float64 {
	raw, ok := o.Lookup(key)
	if !ok {
		return fallback
	}
	var v float64
	if err := json.Unmarshal(raw, &v); err != nil {
		o.warn(key, "float64", err)
		return fallback
	}
	return v
}

// DurationOr returns the overlay value for key parsed as a Go duration string
// (e.g. "30m", "1h"), else fallback. The value is stored as a JSON string.
func (o *Overlay) DurationOr(key string, fallback time.Duration) time.Duration {
	raw, ok := o.Lookup(key)
	if !ok {
		return fallback
	}
	var s string
	if err := json.Unmarshal(raw, &s); err != nil {
		o.warn(key, "duration", err)
		return fallback
	}
	d, err := time.ParseDuration(s)
	if err != nil {
		o.warn(key, "duration-parse", err)
		return fallback
	}
	return d
}

func (o *Overlay) warn(key, kind string, err error) {
	if o != nil && o.logger != nil {
		o.logger.Warn("config overlay: unmarshal", "key", key, "kind", kind, "error", err)
	}
}
