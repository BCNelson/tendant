package chain

import (
	"context"
	"encoding/json"
	"errors"
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
//
// Shutdown safety: a graceful DBOS shutdown cancels the runtime's base
// context, which makes the underlying dbos.Recv return context.Canceled.
// Returning that error to the workflow body would make DBOS record the
// workflow as terminal ERROR — and DBOS only recovers PENDING workflows, never
// ERROR ones. The blocked human slot would then be lost forever: the
// operator's later completeTask / approval Send lands on a dead workflow and
// the task is stuck mid-stage. (Per-task cancellation does NOT reach this path
// — it arrives as a CancelSentinel *message*, not a context error, because
// dbos.CancelWorkflow stops a workflow at the next step boundary and does not
// interrupt a blocked Recv.) So on a shutdown cancellation we deliberately do
// NOT return: we park until the process exits, leaving the workflow PENDING so
// Launch recovery re-runs it on the next boot — replaying the memoized steps
// and re-entering this Recv to wait for the human again.
func WaitForResult(ctx dbos.DBOSContext, topic string, timeout time.Duration) (json.RawMessage, error) {
	msg, err := dbos.Recv[json.RawMessage](ctx, topic, timeout)
	if err != nil && errors.Is(err, context.Canceled) {
		// Runtime shutting down. Park so DBOS leaves this workflow PENDING
		// (recoverable) instead of recording it as terminal ERROR. The
		// process exit tears this goroutine down; Shutdown's drain timeout
		// bounds the wait.
		<-make(chan struct{})
	}
	return msg, err
}

// WaitForWake blocks the readiness gate on a "blocked:<taskID>" topic until a
// wake Send arrives (a blocker reached a terminal state, or a cancellation
// sentinel), or the timeout fires. Unlike WaitForResult, a timeout is NOT
// fatal: it returns (nil, nil) so the gate simply re-evaluates readiness (this
// is how a future start date eventually clears — the wait is sized to expire
// when starts_at passes). Shutdown cancellation is handled identically to
// WaitForResult: park so DBOS leaves the workflow PENDING (recoverable).
func WaitForWake(ctx dbos.DBOSContext, topic string, timeout time.Duration) (json.RawMessage, error) {
	msg, err := dbos.Recv[json.RawMessage](ctx, topic, timeout)
	if err == nil {
		return msg, nil
	}
	if errors.Is(err, context.Canceled) {
		// Runtime shutting down — park (see WaitForResult).
		<-make(chan struct{})
	}
	if errors.Is(err, &dbos.DBOSError{Code: dbos.TimeoutError}) {
		// Timeout is the gate's heartbeat, not a failure — re-evaluate.
		return nil, nil
	}
	return nil, err
}

// Resolve delivers `payload` to the workflow identified by `workflowID` on
// `topic`. Callable from outside any workflow (the GraphQL completeTask
// resolver). The destination workflow's WaitForResult call returns with the
// payload.
func Resolve(ctx dbos.DBOSContext, workflowID, topic string, payload json.RawMessage) error {
	return dbos.Send(ctx, workflowID, payload, topic)
}
