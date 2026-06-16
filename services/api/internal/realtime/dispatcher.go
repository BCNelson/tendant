package realtime

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// Channel is the Phase 0 pg_notify channel.
const Channel = "tendant_events"

// Reconnect backoff bounds for the supervised LISTEN loop.
const (
	minReconnectBackoff = 250 * time.Millisecond
	maxReconnectBackoff = 5 * time.Second
)

// CanFunc is the auth re-check signature; in production it is auth.Can.
// Test code may pass a stub.
type CanFunc func(ctx context.Context, p *auth.Principal, action string, target any) bool

// Dispatcher owns one dedicated pgx.Conn that LISTENs on the Phase 0
// notify channel and fans events out to in-process Subscribers. Per
// subscriber: Match → Can re-check → non-blocking send. The LISTEN conn is
// supervised: if it errors, Run re-acquires a conn, re-LISTENs, and resumes,
// so a transient DB blip never permanently stops realtime for everyone.
type Dispatcher struct {
	mu     sync.RWMutex
	subs   map[*Subscriber]struct{}
	pool   *pgxpool.Pool
	conn   *pgx.Conn
	q      *db.Queries
	canFn  CanFunc
	cancel context.CancelFunc
	done   chan struct{}
}

// New constructs the Dispatcher and establishes the initial LISTEN conn so a
// misconfigured channel/credential surfaces at startup. Call Run in a goroutine
// to start processing notifications (and to supervise reconnects thereafter).
func New(ctx context.Context, pool *pgxpool.Pool, q *db.Queries, canFn CanFunc) (*Dispatcher, error) {
	if canFn == nil {
		canFn = auth.Can
	}
	d := &Dispatcher{
		subs:  map[*Subscriber]struct{}{},
		pool:  pool,
		q:     q,
		canFn: canFn,
		done:  make(chan struct{}),
	}
	if err := d.connect(ctx); err != nil {
		return nil, err
	}
	slog.Info("realtime dispatcher LISTENing", "channel", Channel)
	return d, nil
}

// connect acquires a connection from the pool, hijacks it (detaching it from
// the pool for the LISTEN duration), and issues LISTEN. Sets d.conn on success.
func (d *Dispatcher) connect(ctx context.Context) error {
	conn, err := d.pool.Acquire(ctx)
	if err != nil {
		return fmt.Errorf("acquire pool conn: %w", err)
	}
	hijacked := conn.Hijack()
	if _, err := hijacked.Exec(ctx, "LISTEN "+Channel); err != nil {
		_ = hijacked.Close(ctx)
		return fmt.Errorf("LISTEN %s: %w", Channel, err)
	}
	d.conn = hijacked
	return nil
}

// Run blocks until ctx is cancelled, processing notifications from the
// dedicated LISTEN conn. If the conn errors, it reconnects with backoff and
// resumes — the relay is "always on" for the process lifetime. Spawn a
// goroutine per notification so a slow dispatch never head-of-line-blocks.
func (d *Dispatcher) Run(ctx context.Context) {
	ctx, d.cancel = context.WithCancel(ctx)
	defer close(d.done)
	backoff := minReconnectBackoff
	for {
		if d.conn == nil {
			if err := d.connect(ctx); err != nil {
				if ctx.Err() != nil {
					return
				}
				slog.Warn("dispatcher reconnect failed", "err", err, "retry_in", backoff)
				if !sleepCtx(ctx, backoff) {
					return
				}
				backoff = min(backoff*2, maxReconnectBackoff)
				continue
			}
			slog.Info("dispatcher re-LISTENing after reconnect", "channel", Channel)
			backoff = minReconnectBackoff
		}
		n, err := d.conn.WaitForNotification(ctx)
		if err != nil {
			if errors.Is(err, context.Canceled) || errors.Is(err, context.DeadlineExceeded) {
				return
			}
			// Connection-level failure: drop the conn and reconnect. Events
			// missed during the gap are reconciled by the client's
			// reconnect/foreground refetch.
			slog.Warn("dispatcher WaitForNotification error; reconnecting", "err", err)
			_ = d.conn.Close(ctx)
			d.conn = nil
			continue
		}
		env, perr := parseEnvelope(n.Payload)
		if perr != nil {
			slog.Warn("dispatcher parse envelope failed", "err", perr, "payload", n.Payload)
			continue
		}
		go d.dispatch(ctx, env)
	}
}

// sleepCtx sleeps for d, returning false if ctx is cancelled first.
func sleepCtx(ctx context.Context, d time.Duration) bool {
	t := time.NewTimer(d)
	defer t.Stop()
	select {
	case <-ctx.Done():
		return false
	case <-t.C:
		return true
	}
}

// Stop cancels the Run loop and closes the LISTEN conn. Safe to call once;
// subsequent calls are no-ops.
func (d *Dispatcher) Stop(ctx context.Context) {
	if d.cancel != nil {
		d.cancel()
	}
	<-d.done
	if d.conn != nil {
		_ = d.conn.Close(ctx)
		d.conn = nil
	}
}

// Register adds a subscriber and returns the deregister closure callers
// MUST invoke (typically on subscription resolver exit / ctx done).
func (d *Dispatcher) Register(s *Subscriber) func() {
	d.mu.Lock()
	d.subs[s] = struct{}{}
	d.mu.Unlock()
	return func() {
		d.mu.Lock()
		delete(d.subs, s)
		d.mu.Unlock()
		close(s.Out)
	}
}

// dispatch loads the target entity by topic, per-event re-checks auth for
// every subscriber whose Match accepts the envelope, and non-blocking sends.
// On a full buffer the subscriber is terminated (not silently dropped) so the
// client reconnects and refetches — converting a would-be silent gap into a
// recoverable reconnect.
func (d *Dispatcher) dispatch(ctx context.Context, env EventEnvelope) {
	target, ok := d.loadByTopic(ctx, env.Topic, env.ID)
	if !ok {
		// Row no longer present (deleted, etc.) or the topic is unknown.
		// Drop the event for everyone — there's nothing to authorize.
		return
	}
	d.mu.RLock()
	defer d.mu.RUnlock()
	for s := range d.subs {
		if !s.Match(env.Topic, env.ID) {
			continue
		}
		if !d.canFn(ctx, s.Principal, "view", target) {
			continue
		}
		select {
		case s.Out <- env:
		default:
			// Buffer full: the consumer is too slow / wedged. Terminate it so
			// the websocket drops and the client reconnects + refetches.
			s.DroppedCount.Add(1)
			s.terminate()
		}
	}
}

// loadByTopic loads the row that an envelope describes. Returns (target, ok)
// where ok == false means the row is gone or the topic is unrecognized.
func (d *Dispatcher) loadByTopic(ctx context.Context, topic, idStr string) (any, bool) {
	id, perr := uuid.Parse(idStr)
	if perr != nil {
		return nil, false
	}
	switch topic {
	case "assignment":
		row, err := d.q.GetAgentAssignmentByID(ctx, id)
		if err != nil {
			return nil, false
		}
		return &row, true
	case "decision":
		row, err := d.q.GetPendingDecisionByID(ctx, id)
		if err != nil {
			return nil, false
		}
		return &row, true
	case "task":
		row, err := d.q.GetTask(ctx, id)
		if err != nil {
			return nil, false
		}
		return &row, true
	}
	return nil, false
}

// SubscriberCount is a test/observability hook.
func (d *Dispatcher) SubscriberCount() int {
	d.mu.RLock()
	defer d.mu.RUnlock()
	return len(d.subs)
}
