package overseer_test

import (
	"context"
	"testing"

	"github.com/bcnelson/tendant/services/api/internal/overseer"
)

// BenchmarkGatewayGrade_LogProvider exercises the NFR-001 in-process
// overseer-eval target (p95 < 2 s for LogProvider). LogProvider does no
// network I/O and the cap query is a single index scan, so steady-state
// per-Grade lands in microseconds.
func BenchmarkGatewayGrade_LogProvider(b *testing.B) {
	env := newSeededEnv(b)
	provider := overseer.NewLogProviderWithPattern(nil)
	gw := overseer.NewGateway(provider, env.queries, 1_000_000, "log")
	in := &overseer.OverseerInput{
		TaskID:       env.taskID,
		ConcreteCall: []byte(`{"to":"x","body":"hi"}`),
	}
	ctx := context.Background()

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_, _ = gw.Grade(ctx, in)
	}
}

// BenchmarkPerTaskCapLookup measures the cost of the cap-count query in
// isolation. NFR-001 p99 < 20 ms — the existing idx_audit_task index
// covers it.
func BenchmarkPerTaskCapLookup(b *testing.B) {
	env := newSeededEnv(b)
	// Pre-seed 50 audit rows so the query has realistic input.
	for i := 0; i < 50; i++ {
		_, err := env.pool.Exec(context.Background(), `
			INSERT INTO audit_messages (id, task_id, from_principal, kind, payload, at)
			VALUES (gen_random_uuid(), $1, 'local://principal/system', 'overseer_evaluated', '{}'::jsonb, now())
		`, env.taskID)
		if err != nil {
			b.Fatalf("seed audit row: %v", err)
		}
	}
	ctx := context.Background()

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_, err := env.queries.CountOverseerEvalsForTask(ctx, env.taskID)
		if err != nil {
			b.Fatalf("cap query: %v", err)
		}
	}
}
