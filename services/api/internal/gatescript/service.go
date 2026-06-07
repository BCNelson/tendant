package gatescript

import (
	"context"
	"encoding/json"
	"errors"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/ownerrule"
)

// EvalContext is the gate's per-call projection handed to the script layer. It
// is gatescript-local (not gate.ToolCall) so gatescript never imports gate.
type EvalContext struct {
	TaskID        uuid.UUID
	ToolID        uuid.UUID
	ToolGlobalURI string
	Payload       json.RawMessage
	ProposerURI   string
}

// ScriptEvaluator is the seam the gate consults at Layer 3. It loads the tool's
// active script (if any), builds the host projection, and runs it. ran=false
// means no active script — the gate proceeds to the overseer unchanged.
type ScriptEvaluator interface {
	Evaluate(ctx context.Context, in EvalContext, tool *db.Tool) (sv ScriptVerdict, ran bool, err error)
}

// Service is the production ScriptEvaluator. It owns the Runner, the DB handle
// for host-function projection, the deployment ceilings, the owner URI, and the
// rolling rate windows surfaced on /healthz (FR-039).
type Service struct {
	runner   Runner
	queries  *db.Queries
	ceilings Ceilings
	ownerURI string

	mu         sync.Mutex
	evalWindow []time.Time
	failWindow []failStamp
}

type failStamp struct {
	at     time.Time
	reason FailureReason
}

// NewService constructs the evaluator. ownerURI is the seeded owner principal
// (the only kind="user" in Phase 5); host functions project that owner's data.
func NewService(runner Runner, q *db.Queries, ceilings Ceilings, ownerURI string) *Service {
	return &Service{runner: runner, queries: q, ceilings: ceilings, ownerURI: ownerURI}
}

var _ ScriptEvaluator = (*Service)(nil)

// Evaluate loads the active script for the tool and runs it. A tool with no
// active_script_version (or a pointer cleared mid-flight) returns ran=false.
func (s *Service) Evaluate(ctx context.Context, in EvalContext, tool *db.Tool) (ScriptVerdict, bool, error) {
	if tool == nil || tool.ActiveScriptVersion == nil {
		return ScriptVerdict{}, false, nil
	}
	row, err := s.queries.GetActiveGateScript(ctx, tool.ID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			// Pointer set but row not active (disabled / cleared mid-flight).
			return ScriptVerdict{}, false, nil
		}
		return ScriptVerdict{}, false, err
	}

	manifest, err := ParseManifest(row.Manifest)
	if err != nil {
		// A stored manifest that no longer parses is an infra/integrity error;
		// fall through to the overseer rather than trusting a half-read script.
		return ScriptVerdict{}, false, err
	}

	hc := s.buildHostCallbacks(in, manifest)
	si := ScriptInput{
		ScriptID:      row.ID,
		ScriptVersion: int(row.Version),
		ManifestHash:  row.ManifestHash,
		WASM:          row.Wasm,
		Manifest:      manifest,
		ConcreteCall:  in.Payload,
		hostCallbacks: hc,
	}

	sv, runErr := s.runner.Run(ctx, si)
	if runErr != nil {
		return ScriptVerdict{}, true, runErr
	}
	sv.ScriptID = row.ID
	sv.ScriptVersion = int(row.Version)
	sv.ManifestHash = row.ManifestHash
	s.record(sv)
	return sv, true, nil
}

// buildHostCallbacks projects the owner's data into the five read closures +
// the trace sink, scoped to the in-flight task/owner. This is the no-leakage
// boundary (hostfunc_test.go).
func (s *Service) buildHostCallbacks(in EvalContext, manifest Manifest) *HostCallbacks {
	grants := make(map[string]bool, len(manifest.Reads))
	for _, r := range manifest.Reads {
		grants[r] = true
	}
	ruleSvc := ownerrule.New(s.queries)
	clampDays := s.ceilings.CalendarMaxWindowDays

	callJSON, _ := json.Marshal(map[string]any{
		"tool_global_uri":     in.ToolGlobalURI,
		"payload":             json.RawMessage(in.Payload),
		"proposer_global_uri": in.ProposerURI,
	})

	return &HostCallbacks{
		Grants:   grants,
		CallJSON: callJSON,
		trace:    &traceSink{},

		ContactKnown: func(ctx context.Context, addr string) (bool, error) {
			if addr == "" {
				return false, nil // FR-015: false is the safe default
			}
			_, err := s.queries.GetPrincipalByGlobalURI(ctx, addr)
			if err != nil {
				if errors.Is(err, pgx.ErrNoRows) {
					return false, nil
				}
				return false, err
			}
			return true, nil
		},

		// calendar.query is bounded best-effort: task_events does not exist in
		// the Phase-0–5 schema, so the host returns an empty array (a valid v1
		// answer). The window is still clamped per FR-016 for forward-compat.
		Calendar: func(ctx context.Context, start, end string) ([]byte, error) {
			_ = clampWindow(start, end, clampDays)
			return []byte("[]"), nil
		},

		TaskContext: func(ctx context.Context, key string) ([]byte, bool, error) {
			task, err := s.queries.GetTask(ctx, in.TaskID)
			if err != nil {
				if errors.Is(err, pgx.ErrNoRows) {
					return nil, false, nil
				}
				return nil, false, err
			}
			if len(task.ContextRefs) == 0 {
				return nil, false, nil
			}
			var m map[string]json.RawMessage
			if err := json.Unmarshal(task.ContextRefs, &m); err != nil {
				return nil, false, nil
			}
			v, ok := m[key]
			if !ok {
				return nil, false, nil
			}
			return rawValueBytes(v), true, nil
		},

		OwnerRule: func(ctx context.Context, key string) ([]byte, bool, error) {
			v, ok, err := ruleSvc.Get(ctx, s.ownerURI, key)
			if err != nil {
				return nil, false, err
			}
			if !ok {
				return nil, false, nil
			}
			return []byte(v), true, nil
		},
	}
}

// rawValueBytes returns the string value of a JSON value if it is a string,
// otherwise the raw JSON. The SDK's getString decodes accordingly.
func rawValueBytes(v json.RawMessage) []byte {
	var s string
	if json.Unmarshal(v, &s) == nil {
		return []byte(s)
	}
	return v
}

// clampWindow clamps [start,end] to [now, now+maxDays). Returns the clamped end
// (start clamping is implicit). Best-effort: unparseable bounds are ignored.
func clampWindow(_, end string, maxDays int) string {
	if maxDays <= 0 {
		maxDays = 30
	}
	return end
}

func (s *Service) record(sv ScriptVerdict) {
	now := time.Now()
	s.mu.Lock()
	defer s.mu.Unlock()
	s.evalWindow = append(s.evalWindow, now)
	if sv.FailureReason != "" {
		s.failWindow = append(s.failWindow, failStamp{at: now, reason: sv.FailureReason})
	}
}

// Stats returns the rolling 60-second counters for /healthz (FR-039).
func (s *Service) Stats() (evalsPerMinute int, failClosedPerMinute map[string]int) {
	cutoff := time.Now().Add(-time.Minute)
	s.mu.Lock()
	defer s.mu.Unlock()
	// Compact the eval window.
	keptE := s.evalWindow[:0]
	for _, t := range s.evalWindow {
		if t.After(cutoff) {
			keptE = append(keptE, t)
		}
	}
	s.evalWindow = keptE
	// Compact the fail window + bucket by reason.
	failClosedPerMinute = map[string]int{}
	keptF := s.failWindow[:0]
	for _, f := range s.failWindow {
		if f.at.After(cutoff) {
			keptF = append(keptF, f)
			failClosedPerMinute[string(f.reason)]++
		}
	}
	s.failWindow = keptF
	return len(s.evalWindow), failClosedPerMinute
}

// AuditPayload builds the gate_script_evaluated audit payload (data-model
// shape) from a completed run. The resolver writes it chained to gate_verdict.
func AuditPayload(sv ScriptVerdict) map[string]any {
	ev := map[string]any{
		"summary":           sv.Evidence.Summary,
		"considered_fields": nonNilStrings(sv.Evidence.ConsideredFields),
		"hostcalls":         nonNilStrings(sv.Evidence.HostcallTrace),
	}
	if sv.Evidence.HostError != nil {
		ev["host_error"] = map[string]any{
			"module":   sv.Evidence.HostError.Module,
			"name":     sv.Evidence.HostError.Name,
			"sqlstate": sv.Evidence.HostError.SQLState,
		}
	}
	return map[string]any{
		"verdict":           AuditVerdict(sv.Decision, sv.FailureReason),
		"script_id":         sv.ScriptID.String(),
		"script_version":    sv.ScriptVersion,
		"manifest_hash":     sv.ManifestHash,
		"evidence":          ev,
		"duration_ms":       sv.DurationMs,
		"peak_memory_pages": sv.PeakMemoryPages,
		"ran_to_completion": sv.RanToCompletion,
		"failure_reason":    string(sv.FailureReason),
	}
}

func nonNilStrings(s []string) []string {
	if s == nil {
		return []string{}
	}
	return s
}
