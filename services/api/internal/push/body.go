// Package push is the operator-edge "Channel B" — durable push fan-out via a
// DBOS queue. The Provider interface is the seam (APNs / FCM / LogProvider);
// PushBody is the closed, content-leak-safe payload shape.
package push

// PushBody is the closed shape of every outgoing push payload. Exactly two
// exported fields, by design (FR-015 / SC-003). A reflection-based test in
// body_test.go asserts the field count so adding a "Description" or
// "TaskTitle" can't sneak in.
type PushBody struct {
	DeepLinkID   string
	GenericTitle string
}
