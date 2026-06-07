package intake_test

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/agent"
	"github.com/bcnelson/tendant/services/api/internal/intake"
)

// fakeChat is a minimal agent.AgentModelClient returning a fixed reply.
type fakeChat struct{ content string }

func (f *fakeChat) Chat(_ context.Context, _ agent.ChatRequest) (agent.ChatResponse, error) {
	return agent.ChatResponse{Content: f.content}, nil
}

// These are pure-function unit tests — no DB, fast — for the contract validator,
// the disposition dial parser, and the triage reply parser, which the
// integration tests only exercised indirectly.

func TestSignal_Validate(t *testing.T) {
	base := func() intake.PotentialTaskSignal {
		return intake.PotentialTaskSignal{
			SignalVersion:  intake.SignalVersion,
			SourceID:       "src",
			IdempotencyKey: "k",
			Provenance:     intake.Provenance{RawRef: "ref"},
			Payload:        json.RawMessage(`{}`),
			Disposition:    intake.DispositionForcedTask,
		}
	}
	require.NoError(t, base().Validate())

	cases := map[string]func(s *intake.PotentialTaskSignal){
		"bad version":      func(s *intake.PotentialTaskSignal) { s.SignalVersion = "intake.v2" },
		"missing source":   func(s *intake.PotentialTaskSignal) { s.SourceID = "" },
		"missing key":      func(s *intake.PotentialTaskSignal) { s.IdempotencyKey = "" },
		"missing raw_ref":  func(s *intake.PotentialTaskSignal) { s.Provenance.RawRef = "" },
		"missing payload":  func(s *intake.PotentialTaskSignal) { s.Payload = nil },
		"unknown disposit": func(s *intake.PotentialTaskSignal) { s.Disposition = "nope" },
	}
	for name, mutate := range cases {
		t.Run(name, func(t *testing.T) {
			s := base()
			mutate(&s)
			require.Error(t, s.Validate())
		})
	}
}

func TestParseDispositionRules(t *testing.T) {
	// Empty/nil ⇒ conservative defaults (NFR-003).
	d := intake.ParseDispositionRules(nil)
	require.Equal(t, intake.DefaultConfidenceFloor, d.ConfidenceFloor)
	require.Equal(t, intake.DefaultStakesCeiling, d.StakesCeiling)
	require.Equal(t, intake.DefaultLLMJudgePerPoll, d.LLMJudgePerPoll)

	// Malformed JSON ⇒ defaults (fail-closed), not a panic.
	d = intake.ParseDispositionRules(json.RawMessage(`{not json`))
	require.Equal(t, intake.DefaultConfidenceFloor, d.ConfidenceFloor)

	// Provided fields override; absent fields keep defaults.
	d = intake.ParseDispositionRules(json.RawMessage(`{"confidence_floor":0.5,"llm_judge_per_poll":3}`))
	require.Equal(t, 0.5, d.ConfidenceFloor)
	require.Equal(t, intake.DefaultStakesCeiling, d.StakesCeiling)
	require.Equal(t, 3, d.LLMJudgePerPoll)
}

func TestModelTriageJudge_ParsesVerdict(t *testing.T) {
	// A model client returning a JSON is-task verdict wrapped in prose.
	client := &fakeChat{content: `Sure! {"is_task": false, "title": "Newsletter"} — done.`}
	j := &intake.ModelTriageJudge{Client: client}
	v, err := j.Judge(context.Background(), json.RawMessage(`{"subject":"x"}`))
	require.NoError(t, err)
	require.False(t, v.IsTask)
	require.Equal(t, "Newsletter", v.Title)

	// Unparseable reply ⇒ default is-task=true (surface for owner sign-off; the
	// PROPOSED state already routes to a human, so this never auto-acts).
	client.content = "I cannot tell."
	v, err = j.Judge(context.Background(), json.RawMessage(`{}`))
	require.NoError(t, err)
	require.True(t, v.IsTask)
}

func TestIntakeSignalEvidenceSection_IsLabeled(t *testing.T) {
	out := intake.IntakeSignalEvidenceSection(json.RawMessage(`{"a":1}`))
	require.Contains(t, out, "[INTAKE_SIGNAL]")
	require.Contains(t, out, "[/INTAKE_SIGNAL]")
	require.Contains(t, out, `{"a":1}`)
}
