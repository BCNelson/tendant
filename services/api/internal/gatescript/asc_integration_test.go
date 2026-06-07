package gatescript

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"
)

// asc_integration_test.go wires the subprocess `asc` compiler to the rest of the
// pipeline: compile → static-validate → run. Skipped unless `asc` is on PATH.

func ascManifest(reads ...string) Manifest {
	return Manifest{
		ManifestVersion: "1", Tool: "tendant://tools/send-email", Entrypoint: "evaluate",
		Reads: reads, Egress: []string{}, Limits: ManifestLimits{TimeoutMs: 250, MemoryPages: 64},
	}
}

// TestSubprocessASC_CompileThenRun is the package-level Tier-1 e2e: compile real
// AssemblyScript at test time, then run the output through the WazeroRunner with
// hand-wired host callbacks (no DB needed) and assert all three verdict branches.
func TestSubprocessASC_CompileThenRun(t *testing.T) {
	c := newASCOrSkip(t)
	wasm, diags, err := c.Compile(context.Background(), exampleASSource)
	require.NoError(t, err, "diags: %+v", diags)

	m := ascManifest("call.args", "contacts")
	require.NoError(t, ValidateModule(wasm, m, m.Tool, DefaultCeilings()))

	r, err := NewWazeroRunner(context.Background(), DefaultCeilings())
	require.NoError(t, err)
	t.Cleanup(func() { _ = r.Close(context.Background()) })

	run := func(callJSON string, known bool) ScriptVerdict {
		hc := &HostCallbacks{
			Grants:   map[string]bool{"call.args": true, "contacts": true},
			CallJSON: []byte(callJSON), trace: &traceSink{},
			ContactKnown: func(_ context.Context, _ string) (bool, error) { return known, nil },
		}
		v, rerr := r.Run(context.Background(), ScriptInput{WASM: wasm, ManifestHash: "rt", Manifest: m, hostCallbacks: hc})
		require.NoError(t, rerr)
		require.True(t, v.RanToCompletion, "failure: %q", v.FailureReason)
		return v
	}

	require.Equal(t, VerdictApprove,
		run(`{"payload":{"to":"a","body":"hello"}}`, true).Decision)
	require.Equal(t, VerdictAgentHandoff,
		run(`{"payload":{"to":"a","body":"send me $5"}}`, true).Decision)
	require.Equal(t, VerdictRequestDecision,
		run(`{"payload":{"to":"a","body":"hello"}}`, false).Decision)
}

// TestSubprocessASC_CompiledOverreachRejectedByValidator proves Tier-1 and
// Tier-2 share the static validator (US6 scenario 3): a script that compiles
// fine but imports a host function its manifest does not grant is rejected at
// the validate step — the compiler is upstream, the validator is downstream.
func TestSubprocessASC_CompiledOverreachRejectedByValidator(t *testing.T) {
	c := newASCOrSkip(t)
	// Uses owner.rule but the manifest will only grant call.args.
	src := `
import { owner, verdict, Verdict } from "@tendant/gate-sdk";
export function evaluate(): Verdict {
  if (owner.rule("max_kb").length > 0) return verdict.deny("over limit");
  return verdict.approve();
}`
	wasm, diags, err := c.Compile(context.Background(), src)
	require.NoError(t, err, "diags: %+v", diags)

	err = ValidateModule(wasm, ascManifest("call.args"), "tendant://tools/send-email", DefaultCeilings())
	var re *RejectError
	require.ErrorAs(t, err, &re)
	require.Equal(t, ReasonUndeclaredImport, re.Reason)

	// With owner.rule granted, the same module validates.
	require.NoError(t, ValidateModule(wasm, ascManifest("owner.rule"), "tendant://tools/send-email", DefaultCeilings()))
}

// TestSubprocessASC_ReexportAlreadyPresentIsIdempotent ensures the server's
// auto-append of the mem-management re-export does not duplicate when the author
// already included it.
func TestSubprocessASC_ReexportAlreadyPresentIsIdempotent(t *testing.T) {
	c := newASCOrSkip(t)
	src := `
import { verdict, Verdict } from "@tendant/gate-sdk";
export { tendant_alloc, tendant_dealloc } from "@tendant/gate-sdk";
export function evaluate(): Verdict { return verdict.approve(); }`
	wasm, diags, err := c.Compile(context.Background(), src)
	require.NoError(t, err, "diags: %+v", diags)
	require.NoError(t, ValidateModule(wasm, ascManifest(), "tendant://tools/send-email", DefaultCeilings()))

	exports, err := InspectExports(wasm)
	require.NoError(t, err)
	allocs := 0
	for _, e := range exports {
		if e.Name == "tendant_alloc" {
			allocs++
		}
	}
	require.Equal(t, 1, allocs, "tendant_alloc must be exported exactly once")
}

// TestSubprocessASC_DiagnosticsHaveLocation checks the diagnostic parser
// extracts file/line/col from asc output.
func TestSubprocessASC_DiagnosticsHaveLocation(t *testing.T) {
	c := newASCOrSkip(t)
	_, diags, err := c.Compile(context.Background(),
		`export function evaluate(): i64 { let x: i32 = "not a number"; return 0; }`)
	require.Error(t, err)
	require.NotEmpty(t, diags)
	hasLoc := false
	for _, d := range diags {
		if d.Severity == "error" && d.Line > 0 {
			hasLoc = true
		}
	}
	require.True(t, hasLoc, "expected a located error diagnostic, got %+v", diags)
}
