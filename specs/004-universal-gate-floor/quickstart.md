# Quickstart: Phase 3 — Universal Gate

## End-to-end via GraphiQL

```sh
just up           # postgres + tendant; migrate 00001-00004; seed owner + send-email tool
```

### 1. Create a task and walk it to EXECUTION

The Phase 1/2 happy path: create the task, complete the TRIAGE and EXPANSION assignments. Use the existing test helpers or:

```graphql
mutation { createTask(title: "send a friendly email", description: "say hi to myself") { id } }
# returns task.id = T

# complete TRIAGE
mutation { completeTask(taskId: "T", result: {ok: true}) { id state currentStage } }
# complete EXPANSION (readiness predicate flips state to EXECUTING)
mutation { completeTask(taskId: "T", result: {ok: true}) { id state currentStage } }
```

### 2. Compose a benign tool call

```graphql
mutation {
  proposeToolCall(
    taskId: "T",
    toolGlobalUri: "tendant://tools/send-email",
    payload: {
      to: "tendant://principals/owner",   # known principal → floor does not trip on irreversible-third-party
      subject: "hi",
      body: "hello self"
    }
  ) {
    id
    createdAt
    tool { globalUri }
    payload {
      __typename
      ... on Artifact { kind recipient }
    }
  }
}
# returns ApprovalRequest.id = D
```

The decision is now live in the inbox.

### 3. Receive the wake (optional — subscribe to see it)

```graphql
subscription { inboxItemArrived { __typename ... on ApprovalRequest { id } } }
```

### 4. Approve

```graphql
mutation { approveArtifact(decisionId: "D") { id createdAt } }
```

In the tendant log you should see:

```
level=INFO msg="tools.send_email.dispatch" provider=log to=tendant://principals/owner subject=hi outcome=clean
```

The `tool_outcomes` table now has one `clean` row tied to (`tool_id`, `task_id`).

### 5. Demonstrate the floor

Repeat step 2 but with a **stranger** recipient:

```graphql
mutation {
  proposeToolCall(
    taskId: "T",
    toolGlobalUri: "tendant://tools/send-email",
    payload: { to: "stranger@example.com", subject: "x", body: "y" }
  ) { id payload { ... on Artifact { recipient } } }
}
```

Floor trips on `irreversible_third_party=stranger_recipient`. The decision is **always** created, regardless of the (stubbed) script/overseer verdict. Approving the decision dispatches the call exactly as composed.

### 6. Demonstrate cancel-after-dispatch

After approve, before `completeTask`:

```graphql
mutation { cancelTask(taskId: "T") { id state } }   # → state HALTED
```

The `tool_outcomes` row remains. No new `pending_decisions` rows are created.

## Test scripts

```sh
just test                            # full suite incl. internal/gate floor unit + e2e dispatch
go test -race ./services/api/internal/gate/...
go test -race ./services/api/graph/  -run TestApprovalDispatch
```

## Flutter

```sh
cd apps/mobile && flutter run
```

- Inbox shows ApprovalRequest items.
- Tap → ApprovalDetailPage renders recipient/subject/body.
- Approve → backend dispatches; the item disappears from the inbox.
- Reject → backend records rejection; the item disappears.
- Toggle airplane mode → tap Approve → red banner "requires connectivity".
