package server

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/bcnelson/tendant/services/api/internal/overseer"
)

// RateProvider is the minimum surface healthz needs from the overseer
// gateway. internal/overseer.Gateway satisfies it.
type RateProvider interface {
	RatePerMinute() int
}

// GateScriptRateProvider is the surface healthz needs from the gate-script
// evaluator (FR-039). internal/gatescript.Service satisfies it.
type GateScriptRateProvider interface {
	Stats() (evalsPerMinute int, failClosedPerMinute map[string]int)
}

// IntakeRateProvider is the surface healthz needs from the intake edge (T059).
// internal/intake.Metrics satisfies it.
type IntakeRateProvider interface {
	Snapshot() (emitted, deduped, capped int)
}

type healthzResponse struct {
	OK         bool                    `json:"ok"`
	Overseer   *healthzOverseerBlock   `json:"overseer,omitempty"`
	GateScript *healthzGateScriptBlock `json:"gatescript,omitempty"`
	Intake     *healthzIntakeBlock     `json:"intake,omitempty"`
}

type healthzIntakeBlock struct {
	SignalsEmittedPerMinute int `json:"signals_emitted_per_minute"`
	SignalsDedupedPerMinute int `json:"signals_deduped_per_minute"`
	LLMJudgeCappedPerMinute int `json:"llm_judge_capped_per_minute"`
}

type healthzOverseerBlock struct {
	EvaluationsPerMinute int `json:"evaluations_per_minute"`
}

type healthzGateScriptBlock struct {
	EvaluationsPerMinute int            `json:"evaluations_per_minute"`
	FailClosedPerMinute  map[string]int `json:"fail_closed_per_minute"`
}

// healthzWithOverseer extends the Phase 0 healthz with the overseer counter
// (FR-010) and the Phase-5 gate-script counters (FR-039). Either provider may
// be nil in tests that don't drive that layer; the block is omitted then.
func healthzWithOverseer(pool *pgxpool.Pool, gateway RateProvider, scripts GateScriptRateProvider, intakeRate IntakeRateProvider) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
		defer cancel()
		if err := pool.Ping(ctx); err != nil {
			http.Error(w, "db unavailable", http.StatusServiceUnavailable)
			return
		}
		resp := healthzResponse{OK: true}
		if gateway != nil {
			resp.Overseer = &healthzOverseerBlock{
				EvaluationsPerMinute: gateway.RatePerMinute(),
			}
		}
		if scripts != nil {
			evals, failed := scripts.Stats()
			if failed == nil {
				failed = map[string]int{}
			}
			resp.GateScript = &healthzGateScriptBlock{
				EvaluationsPerMinute: evals,
				FailClosedPerMinute:  failed,
			}
		}
		if intakeRate != nil {
			emitted, deduped, capped := intakeRate.Snapshot()
			resp.Intake = &healthzIntakeBlock{
				SignalsEmittedPerMinute: emitted,
				SignalsDedupedPerMinute: deduped,
				LLMJudgeCappedPerMinute: capped,
			}
		}
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(resp)
	}
}

// compile-time assertion: *overseer.Gateway implements RateProvider.
var _ RateProvider = (*overseer.Gateway)(nil)
