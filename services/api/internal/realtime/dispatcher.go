package realtime

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"sync"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/auth"
	"github.com/bcnelson/tendant/services/api/internal/db"
)

// Channel is the Phase 0 pg_notify channel.
const Channel = "tendant_events"

// CanFunc is the auth re-check signature; in production it is auth.Can.
// Test code may pass a stub.
type CanFunc func(ctx context.Context, p *auth.Principal, action string, target any) bool

// Dispatcher owns one dedicated pgx.Conn that LISTENs on the Phase 0
// notify channel and fans events out to in-process Subscribers. Per
// subscriber: Match → Can re-check → non-blocking send.
type Dispatcher struct {
	mu     sync.RWMutex
	subs   map[*Subscriber]struct{}
	conn   *pgx.Conn
	q      *db.Queries
	canFn  CanFunc
	cancel context.CancelFunc
	done   chan struct{}
}

// New acquires a dedicated pgx.Conn from the pool, issues LISTEN, and returns
// the Dispatcher. Call Run on the returned dispatcher in a goroutine to start
// processing notifications.
func New(ctx context.Context, pool *pgxpool.Pool, q *db.Queries, canFn CanFunc) (*Dispatcher, error) {
	if canFn == nil {
		canFn = auth.Can
	}
	// Acquire a connection and detach it from the pool so we can hold it
	// for the LISTEN duration. pgxpool.Pool.Acquire returns a Conn that we
	// hijack with Conn().Hijack() to extract the underlying *pgx.Conn.
	conn, err := pool.Acquire(ctx)
	if err != nil {
		return nil, fmt.Errorf("acquire pool conn: %w", err)
	}
	hijacked := conn.Hijack()
	if _, err := hijacked.Exec(ctx, "LISTEN "+Channel); err != nil {
		_ = hijacked.Close(ctx)
		return nil, fmt.Errorf("LISTEN %s: %w", Channel, err)
	}
	slog.Info("realtime dispatcher LISTENing", "channel", Channel)
	return &Dispatcher{
		subs:  map[*Subscriber]struct{}{},
		conn:  hijacked,
		q:     q,
		canFn: canFn,
		done:  make(chan struct{}),
	}, nil
}

// Run blocks until ctx is cancelled, processing notifications from the
// dedicated LISTEN conn. Spawn a goroutine per notification so a slow
// dispatch never head-of-line-blocks the loop.
func (d *Dispatcher) Run(ctx context.Context) {
	ctx, d.cancel = context.WithCancel(ctx)
	defer close(d.done)
	for {
		n, err := d.conn.WaitForNotification(ctx)
		if err != nil {
			if errors.Is(err, context.Canceled) || errors.Is(err, context.DeadlineExceeded) {
				return
			}
			slog.Warn("dispatcher WaitForNotification error", "err", err)
			return
		}
		env, perr := parseEnvelope(n.Payload)
		if perr != nil {
			slog.Warn("dispatcher parse envelope failed", "err", perr, "payload", n.Payload)
			continue
		}
		go d.dispatch(ctx, env)
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
			s.DroppedCount.Add(1)
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
