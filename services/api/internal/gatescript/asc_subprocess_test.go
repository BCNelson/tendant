package gatescript

import (
	"context"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

// asc_subprocess_test.go covers the opt-in Tier-1 server-compile backend. It is
// skipped unless `asc` is on PATH (run it inside the devenv shell, or via
// `nix shell nixpkgs#assemblyscript --command go test ./internal/gatescript/`).
// SC-012 / SC-006.

const exampleASSource = `
import { call, contacts, verdict, Verdict } from "@tendant/gate-sdk";
function fieldOf(json: string, key: string): string {
  const n = "\"" + key + "\":\""; const i = json.indexOf(n); if (i < 0) return "";
  const s = i + n.length; const e = json.indexOf("\"", s); return e < 0 ? "" : json.substring(s, e);
}
export function evaluate(): Verdict {
  const c = call.get();
  const to = fieldOf(c, "to");
  if (!contacts.isKnown(to)) return verdict.requestDecision("unknown recipient " + to);
  if (fieldOf(c, "body").includes("$")) return verdict.agentHandoff("mentions money");
  return verdict.approve();
}`

func newASCOrSkip(t *testing.T) *SubprocessASCCompiler {
	t.Helper()
	c, err := NewSubprocessASCCompiler()
	if err != nil {
		t.Skip("asc not on PATH — run inside devenv or `nix shell nixpkgs#assemblyscript`")
	}
	return c
}

func TestSubprocessASC_CompilesValidGateScript(t *testing.T) {
	c := newASCOrSkip(t)

	wasm, diags, err := c.Compile(context.Background(), exampleASSource)
	require.NoError(t, err, "diags: %+v", diags)
	require.NotEmpty(t, wasm)

	// The compiled module passes static validation (clean exports + imports ⊆
	// reads) — proving the server-compile → validate pipeline (SC-006).
	const tool = "tendant://tools/send-email"
	manifest := Manifest{
		ManifestVersion: "1", Tool: tool, Entrypoint: "evaluate",
		Reads: []string{"call.args", "contacts"}, Egress: []string{},
		Limits: ManifestLimits{TimeoutMs: 250, MemoryPages: 64},
	}
	require.NoError(t, ValidateModule(wasm, manifest, tool, DefaultCeilings()))

	// Sanity-check the exports are exactly the ABI set.
	exports, err := InspectExports(wasm)
	require.NoError(t, err)
	got := map[string]bool{}
	for _, e := range exports {
		if e.Kind == extFunc {
			got[e.Name] = true
		}
	}
	require.True(t, got["evaluate"] && got["tendant_alloc"] && got["tendant_dealloc"],
		"missing ABI exports: %v", got)
}

func TestSubprocessASC_MalformedSourceFails(t *testing.T) {
	c := newASCOrSkip(t)

	_, diags, err := c.Compile(context.Background(), `export function evaluate(): i64 { return notAThing(); }`)
	require.Error(t, err, "malformed source must fail to compile")
	require.NotEmpty(t, diags, "compile failure must surface diagnostics")
	hasError := false
	for _, d := range diags {
		if d.Severity == "error" {
			hasError = true
		}
	}
	require.True(t, hasError, "expected an error-severity diagnostic, got %+v", diags)
}

func TestSubprocessASC_UnavailableWhenAscMissing(t *testing.T) {
	// Documents the default-disabled behaviour: CompileAssemblyScript returns
	// ErrASCUnavailable until a backend is installed via SetASCCompiler.
	if _, err := NewSubprocessASCCompiler(); err != nil {
		require.ErrorIs(t, err, ErrASCUnavailable)
		require.True(t, strings.Contains(err.Error(), "unavailable"))
	}
}
