package chain

import (
	"encoding/json"
	"time"

	"github.com/dbos-inc/dbos-transact-golang/dbos"
)

// HumanSlotTimeout is how long the chain workflow's durable wait will sit on
// a human slot before returning an error. Three days is long enough that
// ordinary human latency never trips it; if a slot truly sits this long, the
// workflow errors and the operator decides next step (re-open, cancel, or
// extend).
const HumanSlotTimeout = 72 * time.Hour

// WaitForResult blocks the calling workflow on `topic` until either a
// matching Send arrives or the timeout fires. The signature is intentionally
// generic — no `stage`, `assignment`, `principal`, or `task` parameter — so
// later phases (approvals, sub-agent questions, tool results) can reuse it
// without new machinery (FR-009 / SC-004).
//
// The returned RawMessage is the serialized payload that the resolver passed
// to Resolve below.
func WaitForResult(ctx dbos.DBOSContext, topic string, timeout time.Duration) (json.RawMessage, error) {
	return dbos.Recv[json.RawMessage](ctx, topic, timeout)
}

// Resolve delivers `payload` to the workflow identified by `workflowID` on
// `topic`. Callable from outside any workflow (the GraphQL completeTask
// resolver). The destination workflow's WaitForResult call returns with the
// payload.
func Resolve(ctx dbos.DBOSContext, workflowID, topic string, payload json.RawMessage) error {
	return dbos.Send(ctx, workflowID, payload, topic)
}
