package server_test

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/db"
	"github.com/bcnelson/tendant/services/api/internal/gatescript"
	"github.com/bcnelson/tendant/services/api/internal/server"
	"github.com/bcnelson/tendant/services/api/internal/testutil"
)

// healthz_phase5_test.go drives the REAL server.New router and asserts /healthz
// exposes the Phase-5 gate-script block (FR-039). This is a deploy smoke: an
// orchestrator's readiness probe must see the new shape on first boot.
func TestHealthz_ExposesGateScriptBlock(t *testing.T) {
	ctx := context.Background()
	pool := testutil.TestDB(t)
	require.NoError(t, db.Migrate(ctx, pool.Config().ConnConfig.ConnString()))

	// A real Service (LogRunner — no DB calls for Stats) satisfies both the
	// ScriptEvaluator option and the GateScriptRateProvider healthz interface.
	svc := gatescript.NewService(gatescript.NewLogRunner(), db.New(pool), gatescript.DefaultCeilings(), "tendant://principals/owner")
	handler := server.New(pool, nil, server.Options{GateScript: svc})

	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/healthz", nil))
	require.Equal(t, http.StatusOK, rec.Code, "body=%s", rec.Body.String())

	var resp struct {
		OK         bool `json:"ok"`
		GateScript *struct {
			EvaluationsPerMinute int            `json:"evaluations_per_minute"`
			FailClosedPerMinute  map[string]int `json:"fail_closed_per_minute"`
		} `json:"gatescript"`
	}
	require.NoError(t, json.Unmarshal(rec.Body.Bytes(), &resp))
	require.True(t, resp.OK)
	require.NotNil(t, resp.GateScript, "/healthz must include the gatescript block when wired")
	require.NotNil(t, resp.GateScript.FailClosedPerMinute, "fail_closed_per_minute must be present (object, never null)")
}

// Without a gate-script Service wired, the block is omitted (not an error) — the
// Phase-0/4 deployments still serve /healthz.
func TestHealthz_OmitsGateScriptBlockWhenUnwired(t *testing.T) {
	ctx := context.Background()
	pool := testutil.TestDB(t)
	require.NoError(t, db.Migrate(ctx, pool.Config().ConnConfig.ConnString()))

	handler := server.New(pool, nil, server.Options{})
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/healthz", nil))
	require.Equal(t, http.StatusOK, rec.Code)

	var resp map[string]any
	require.NoError(t, json.Unmarshal(rec.Body.Bytes(), &resp))
	require.Equal(t, true, resp["ok"])
	_, present := resp["gatescript"]
	require.False(t, present, "gatescript block omitted when no evaluator is wired")
}
