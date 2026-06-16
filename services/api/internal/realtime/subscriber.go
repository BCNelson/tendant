package realtime

import (
	"sync"
	"sync/atomic"

	"github.com/bcnelson/tendant/services/api/internal/auth"
)

// Subscriber is the in-process listener registered with the Dispatcher.
// Channel capacity is fixed at 32. On overflow the Dispatcher does NOT silently
// drop and leave the client stale — it terminates the subscriber (closes Done),
// so the stream pump exits and the websocket subscription ends. The client's WS
// layer reconnects and its reconnect/foreground refetch reconciles the gap. A
// dropped event thus degrades to "reconnect + refetch", never silent staleness.
type Subscriber struct {
	Principal    *auth.Principal
	Match        func(topic, id string) bool
	Out          chan EventEnvelope
	DroppedCount atomic.Int64

	// Done is closed (once) when the subscriber is terminated by the
	// Dispatcher on buffer overflow. Stream pumps select on it to exit.
	Done      chan struct{}
	closeOnce sync.Once
}

// terminate signals the stream pump to exit. Idempotent and safe to call from
// multiple concurrent dispatch goroutines (it only closes Done, never Out — Out
// is closed exactly once by the stream pump's dereg on exit).
func (s *Subscriber) terminate() {
	s.closeOnce.Do(func() { close(s.Done) })
}

// DefaultSubscriberCapacity is the bounded channel size for every subscriber.
const DefaultSubscriberCapacity = 32

// NewInboxSubscriber returns a Subscriber that matches every event (the
// inboxItemArrived subscription is fully scoped at the per-event Can re-check).
func NewInboxSubscriber(p *auth.Principal) *Subscriber {
	return &Subscriber{
		Principal: p,
		Match:     func(string, string) bool { return true },
		Out:       make(chan EventEnvelope, DefaultSubscriberCapacity),
		Done:      make(chan struct{}),
	}
}

// NewTaskChangedSubscriber returns a Subscriber that matches taskID-scoped
// events, or every task event when taskID == nil.
func NewTaskChangedSubscriber(p *auth.Principal, taskID *string) *Subscriber {
	match := func(topic, id string) bool {
		if topic != "task" && topic != "assignment" && topic != "decision" {
			return false
		}
		if taskID == nil {
			return true
		}
		return id == *taskID
	}
	return &Subscriber{
		Principal: p,
		Match:     match,
		Out:       make(chan EventEnvelope, DefaultSubscriberCapacity),
		Done:      make(chan struct{}),
	}
}

// NewNotificationSubscriber matches only `notification` topics. Phase 2
// emits no such events; the channel stays open without firing.
func NewNotificationSubscriber(p *auth.Principal) *Subscriber {
	return &Subscriber{
		Principal: p,
		Match:     func(topic, _ string) bool { return topic == "notification" },
		Out:       make(chan EventEnvelope, DefaultSubscriberCapacity),
		Done:      make(chan struct{}),
	}
}
