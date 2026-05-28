package realtime

import (
	"sync/atomic"

	"github.com/bcnelson/tendant/services/api/internal/auth"
)

// Subscriber is the in-process listener registered with the Dispatcher.
// Channel capacity is fixed at 32 — over-subscription drops the event and
// increments DroppedCount (research R4 slow-subscriber policy).
type Subscriber struct {
	Principal    *auth.Principal
	Match        func(topic, id string) bool
	Out          chan EventEnvelope
	DroppedCount atomic.Int64
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
	}
}

// NewNotificationSubscriber matches only `notification` topics. Phase 2
// emits no such events; the channel stays open without firing.
func NewNotificationSubscriber(p *auth.Principal) *Subscriber {
	return &Subscriber{
		Principal: p,
		Match:     func(topic, _ string) bool { return topic == "notification" },
		Out:       make(chan EventEnvelope, DefaultSubscriberCapacity),
	}
}
