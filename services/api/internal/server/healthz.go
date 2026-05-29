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

type healthzResponse struct {
	OK       bool                  `json:"ok"`
	Overseer *healthzOverseerBlock `json:"overseer,omitempty"`
}

type healthzOverseerBlock struct {
	EvaluationsPerMinute int `json:"evaluations_per_minute"`
}

// healthzWithOverseer extends the Phase 0 healthz to include the
// overseer evaluations-per-minute counter (FR-010). gateway may be nil
// in tests that don't drive the overseer; in that case the field is
// omitted (omitempty).
func healthzWithOverseer(pool *pgxpool.Pool, gateway RateProvider) http.HandlerFunc {
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
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(resp)
	}
}

// compile-time assertion: *overseer.Gateway implements RateProvider.
var _ RateProvider = (*overseer.Gateway)(nil)
