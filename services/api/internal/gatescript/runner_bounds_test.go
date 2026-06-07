package gatescript

import (
	"context"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgconn"
	"github.com/stretchr/testify/require"
)

// runner_bounds_test.go covers the two fail-closed paths the hand-built verdict
// fixtures don't reach: the memory ceiling (a module whose declared minimum
// memory exceeds the deployment cap) and a host-function error (FR-007 / Q4 —
// the host traps the script rather than handing it a legitimate-looking empty
// read).

// bigMemoryModule builds a valid approve module that declares `minPages` of
// initial memory — instantiation fails when minPages exceeds the runner's cap.
func bigMemoryModule(minPages int) []byte {
	header := []byte{0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00}
	t0 := []byte{0x60, 0x00, 0x01, 0x7E}
	t1 := []byte{0x60, 0x01, 0x7F, 0x01, 0x7F}
	t2 := []byte{0x60, 0x02, 0x7F, 0x7F, 0x00}
	typeSec := sec(1, vec(3, concat(t0, t1, t2)))
	funcSec := sec(3, vec(3, []byte{0x00, 0x01, 0x02}))
	memSec := sec(5, vec(1, concat([]byte{0x00}, uLEB(uint64(minPages))))) // limits{min=minPages}
	exportSec := sec(7, vec(4, concat(
		name("memory"), []byte{0x02, 0x00},
		name("evaluate"), []byte{0x00, 0x00},
		name("tendant_alloc"), []byte{0x00, 0x01},
		name("tendant_dealloc"), []byte{0x00, 0x02},
	)))
	verdict := []byte(`{"decision":"approve","evidence":{"summary":"x","considered_fields":[]}}`)
	packed := (int64(1024) << 32) | int64(len(verdict))
	evalInner := concat([]byte{0x00}, []byte{0x42}, sLEB(packed), []byte{0x0B})
	evalBody := append(uLEB(uint64(len(evalInner))), evalInner...)
	allocInner := concat([]byte{0x00}, []byte{0x41}, sLEB(4096), []byte{0x0B})
	allocBody := append(uLEB(uint64(len(allocInner))), allocInner...)
	deallocBody := append(uLEB(2), []byte{0x00, 0x0B}...)
	codeSec := sec(10, vec(3, concat(evalBody, allocBody, deallocBody)))
	offsetExpr := concat([]byte{0x41}, sLEB(1024), []byte{0x0B})
	segment := concat([]byte{0x00}, offsetExpr, uLEB(uint64(len(verdict))), verdict)
	dataSec := sec(11, vec(1, segment))
	return concat(header, typeSec, funcSec, memSec, exportSec, codeSec, dataSec)
}

func TestWazeroRunner_MemoryCap_FailsClosed(t *testing.T) {
	// Runner cap is 64 pages; the module wants 256 initial pages.
	r, err := NewWazeroRunner(context.Background(), Ceilings{MaxTimeoutMs: 1000, MaxMemoryPages: 64})
	require.NoError(t, err)
	t.Cleanup(func() { _ = r.Close(context.Background()) })

	v, err := r.Run(context.Background(), ScriptInput{
		WASM: bigMemoryModule(256), ManifestHash: "bigmem",
		Manifest: Manifest{Limits: ManifestLimits{TimeoutMs: 250, MemoryPages: 64}},
	})
	require.NoError(t, err)
	require.False(t, v.RanToCompletion, "a module over the memory cap must fail closed")
	require.Equal(t, FailureMemoryCap, v.FailureReason)
	require.Equal(t, VerdictAgentHandoff, v.Decision)
}

func TestWazeroRunner_HostError_TrapsAndFailsClosed(t *testing.T) {
	// Run the REAL asc-compiled send-email module (it calls contacts.isKnown),
	// but wire a host callback that errors with a Postgres SQLSTATE. The runner
	// must trap the script and report fail_closed_host_error with the
	// (module, name, sqlstate) context — never a silent empty read (FR-007).
	wasm, err := os.ReadFile("testdata/send_email_as.wasm")
	require.NoError(t, err)

	r, err := NewWazeroRunner(context.Background(), DefaultCeilings())
	require.NoError(t, err)
	t.Cleanup(func() { _ = r.Close(context.Background()) })

	hc := &HostCallbacks{
		Grants:   map[string]bool{"call.args": true, "contacts": true},
		CallJSON: []byte(`{"tool_global_uri":"tendant://tools/send-email","payload":{"to":"someone","body":"hi"},"proposer_global_uri":"o"}`),
		trace:    &traceSink{},
		ContactKnown: func(_ context.Context, _ string) (bool, error) {
			return false, &pgconn.PgError{Code: "53300", Message: "too many connections"}
		},
	}

	v, err := r.Run(context.Background(), ScriptInput{
		WASM: wasm, ManifestHash: "real",
		Manifest:      Manifest{Reads: []string{"call.args", "contacts"}, Limits: ManifestLimits{TimeoutMs: 250, MemoryPages: 64}},
		hostCallbacks: hc,
	})
	require.NoError(t, err)
	require.False(t, v.RanToCompletion)
	require.Equal(t, FailureHostError, v.FailureReason)
	require.Equal(t, VerdictAgentHandoff, v.Decision, "host error must fail OPEN to the overseer")
	require.NotNil(t, v.Evidence.HostError)
	require.Equal(t, "contacts", v.Evidence.HostError.Module)
	require.Equal(t, "isKnown", v.Evidence.HostError.Name)
	require.Equal(t, "53300", v.Evidence.HostError.SQLState)
}

func TestWazeroRunner_HostError_UngrantedCapabilityTraps(t *testing.T) {
	// Defense-in-depth: even though static validation rejects undeclared
	// imports at upload, a module that reaches a host function whose capability
	// was not granted must trap at runtime (not silently succeed).
	wasm, err := os.ReadFile("testdata/send_email_as.wasm")
	require.NoError(t, err)

	r, err := NewWazeroRunner(context.Background(), DefaultCeilings())
	require.NoError(t, err)
	t.Cleanup(func() { _ = r.Close(context.Background()) })

	// call.args is granted but contacts is NOT — the script calls contacts.isKnown.
	hc := &HostCallbacks{
		Grants:       map[string]bool{"call.args": true},
		CallJSON:     []byte(`{"payload":{"to":"x","body":"hi"}}`),
		trace:        &traceSink{},
		ContactKnown: func(_ context.Context, _ string) (bool, error) { return true, nil },
	}
	v, err := r.Run(context.Background(), ScriptInput{
		WASM: wasm, ManifestHash: "ungranted",
		Manifest:      Manifest{Reads: []string{"call.args"}, Limits: ManifestLimits{TimeoutMs: 250, MemoryPages: 64}},
		hostCallbacks: hc,
	})
	require.NoError(t, err)
	require.False(t, v.RanToCompletion, "an ungranted host call must fail closed")
	require.Equal(t, VerdictAgentHandoff, v.Decision)
}
