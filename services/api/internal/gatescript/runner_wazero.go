package gatescript

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"sync"
	"time"

	"github.com/tetratelabs/wazero"
	"github.com/tetratelabs/wazero/api"
	"github.com/tetratelabs/wazero/sys"
)

// WazeroRunner is the production Runner: a sandboxed, read-only, bounded WASM
// evaluator. The runtime + compilation cache + shared "tendant" host module are
// process-lifetime; each Run instantiates the guest fresh under a timeout
// context and a linear-memory cap. Per-call host state travels via context
// (see hostcalls.go), so the single shared host module serves concurrent calls.
//
// Every runtime failure path — timeout, memory cap, trap, malformed return,
// host error — converts to ScriptVerdict{Decision: AgentHandoff,
// RanToCompletion: false, FailureReason: …} (FR-007). The runner NEVER treats a
// failure as Approve.
type WazeroRunner struct {
	runtime  wazero.Runtime
	ceilings Ceilings

	mu       sync.Mutex
	compiled map[string]wazero.CompiledModule // keyed by manifest_hash
}

// NewWazeroRunner builds the runtime (with a compilation cache) and instantiates
// the shared host module. Call Close at shutdown.
func NewWazeroRunner(ctx context.Context, ceilings Ceilings) (*WazeroRunner, error) {
	cache := wazero.NewCompilationCache()
	memLimit := uint32(ceilings.MaxMemoryPages)
	if memLimit == 0 {
		memLimit = 256
	}
	rt := wazero.NewRuntimeWithConfig(ctx, wazero.NewRuntimeConfig().
		WithCompilationCache(cache).
		WithCloseOnContextDone(true).   // honor timeout/cancel by closing the module
		WithMemoryLimitPages(memLimit)) // deployment memory ceiling (FR-013)

	r := &WazeroRunner{
		runtime:  rt,
		ceilings: ceilings,
		compiled: make(map[string]wazero.CompiledModule),
	}
	if err := r.instantiateHostModule(ctx); err != nil {
		_ = rt.Close(ctx)
		return nil, fmt.Errorf("instantiate host module: %w", err)
	}
	return r, nil
}

// Close releases the runtime.
func (r *WazeroRunner) Close(ctx context.Context) error {
	return r.runtime.Close(ctx)
}

var _ Runner = (*WazeroRunner)(nil)

// Run implements Runner. Per the ABI, the guest exports evaluate() -> i64
// (packed ptr<<32|len) plus memory + tendant_alloc/tendant_dealloc.
func (r *WazeroRunner) Run(ctx context.Context, in ScriptInput) (ScriptVerdict, error) {
	start := time.Now()
	hc := hostCallbacksFromInput(in)

	compiled, err := r.compile(ctx, in)
	if err != nil {
		// A compile failure at eval time (should not happen — validated at
		// upload) fails open to the overseer. classifyFailure distinguishes an
		// over-cap memory section (memory_cap) from other compile traps.
		return classifyFailure(err, ctx, start, hc), nil
	}

	// Apply the effective timeout (min(manifest, ceiling)).
	timeout := time.Duration(in.Manifest.EffectiveTimeoutMs(r.ceilings)) * time.Millisecond
	runCtx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()
	runCtx = withHostCallbacks(runCtx, hc)

	// Memory cap: the guest's max memory pages. Enforced via ModuleConfig.
	cfg := wazero.NewModuleConfig().WithName("") // anonymous → concurrency-safe
	mod, err := r.runtime.InstantiateModule(runCtx, compiled, cfg)
	if err != nil {
		return classifyFailure(err, runCtx, start, hc), nil
	}
	defer mod.Close(context.Background())

	evaluate := mod.ExportedFunction("evaluate")
	if evaluate == nil {
		return failClosed(FailureMalformedReturn, start, hc), nil
	}

	results, err := evaluate.Call(runCtx)
	if err != nil {
		// A host-callback error trapped the script: report it as host_error
		// (not a generic trap) so the audit row carries the SQLSTATE context.
		if hc.hostErr != nil {
			v := failClosed(FailureHostError, start, hc)
			v.Evidence.HostError = hc.hostErr
			return v, nil
		}
		return classifyFailure(err, runCtx, start, hc), nil
	}
	if len(results) != 1 {
		return failClosed(FailureMalformedReturn, start, hc), nil
	}

	verdict, derr := decodeVerdict(mod, results[0])
	if derr != nil {
		return failClosed(FailureMalformedReturn, start, hc), nil
	}

	// A host error recorded during the run traps the verdict (FR-007) even if
	// the guest returned a well-formed decision — a transient DB blip must not
	// masquerade as a legitimate empty read.
	if hc.hostErr != nil {
		v := failClosed(FailureHostError, start, hc)
		v.Evidence.HostError = hc.hostErr
		return v, nil
	}

	dec, ok := decisionFromString(verdict.Decision)
	if !ok {
		return failClosed(FailureMalformedReturn, start, hc), nil
	}

	return ScriptVerdict{
		Decision: dec,
		Evidence: Evidence{
			Summary:          truncateUTF8(verdict.Evidence.Summary, maxSummaryBytes),
			ConsideredFields: capFields(verdict.Evidence.ConsideredFields),
			HostcallTrace:    hc.trace.snapshot(),
		},
		DurationMs:      int(time.Since(start).Milliseconds()),
		PeakMemoryPages: int(mod.Memory().Size() / 65536),
		RanToCompletion: true,
	}, nil
}

func (r *WazeroRunner) compile(ctx context.Context, in ScriptInput) (wazero.CompiledModule, error) {
	// Key by the WASM bytes, NOT the manifest hash: two different modules can
	// ship the same manifest (same tool/reads/limits), so manifest_hash is not
	// 1:1 with the bytes. sha256(wasm) is the correct cache key.
	sum := sha256.Sum256(in.WASM)
	key := hex.EncodeToString(sum[:])
	r.mu.Lock()
	c, ok := r.compiled[key]
	r.mu.Unlock()
	if ok {
		return c, nil
	}
	c, err := r.runtime.CompileModule(ctx, in.WASM)
	if err != nil {
		return nil, err
	}
	r.mu.Lock()
	r.compiled[key] = c
	r.mu.Unlock()
	return c, nil
}

// wireVerdict is the JSON the guest writes (ABI §Verdict JSON shape).
type wireVerdict struct {
	Decision string `json:"decision"`
	Evidence struct {
		Summary          string   `json:"summary"`
		ConsideredFields []string `json:"considered_fields"`
	} `json:"evidence"`
}

// decodeVerdict reads the packed (ptr,len) i64 the guest returned, reads that
// region from guest memory, and parses the verdict JSON.
func decodeVerdict(mod api.Module, packed uint64) (wireVerdict, error) {
	ptr := uint32(packed >> 32)
	length := uint32(packed & 0xFFFFFFFF)
	if length == 0 || length > (1<<20) { // bound the read to 1 MiB
		return wireVerdict{}, errors.New("verdict length out of range")
	}
	buf, ok := mod.Memory().Read(ptr, length)
	if !ok {
		return wireVerdict{}, errors.New("verdict pointer out of bounds")
	}
	var v wireVerdict
	if err := json.Unmarshal(buf, &v); err != nil {
		return wireVerdict{}, err
	}
	return v, nil
}

// classifyFailure maps a wazero error to the right FailureReason. A deadline-
// exceeded context means timeout; an out-of-memory grow trap means memory cap;
// anything else is a generic trap.
func classifyFailure(err error, ctx context.Context, start time.Time, hc *HostCallbacks) ScriptVerdict {
	if ctx.Err() == context.DeadlineExceeded {
		return failClosed(FailureTimeout, start, hc)
	}
	// wazero surfaces an over-cap memory as an instantiation/grow failure whose
	// message mentions "memory" (e.g. "module[...] memory size ... over limit").
	// Classify those as memory_cap; everything else (unreachable, OOB access,
	// sys.ExitError) is a generic trap. Either way the run fails closed.
	if msg := err.Error(); strings.Contains(msg, "memory") {
		return failClosed(FailureMemoryCap, start, hc)
	}
	var exit *sys.ExitError
	if errors.As(err, &exit) {
		return failClosed(FailureTrap, start, hc)
	}
	return failClosed(FailureTrap, start, hc)
}

func failClosed(reason FailureReason, start time.Time, hc *HostCallbacks) ScriptVerdict {
	var trace []string
	if hc != nil && hc.trace != nil {
		trace = hc.trace.snapshot()
	}
	return ScriptVerdict{
		Decision:        VerdictAgentHandoff,
		Evidence:        Evidence{ConsideredFields: []string{}, HostcallTrace: trace},
		DurationMs:      int(time.Since(start).Milliseconds()),
		RanToCompletion: false,
		FailureReason:   reason,
	}
}

func decisionFromString(s string) (Verdict, bool) {
	switch s {
	case "approve":
		return VerdictApprove, true
	case "deny":
		return VerdictDeny, true
	case "request_decision":
		return VerdictRequestDecision, true
	case "agent_handoff":
		return VerdictAgentHandoff, true
	default:
		return 0, false
	}
}

func capFields(fields []string) []string {
	if fields == nil {
		return []string{}
	}
	if len(fields) > maxConsideredFields {
		return fields[:maxConsideredFields]
	}
	return fields
}

// hostCallbacksFromInput pulls the per-call HostCallbacks the Service stashed on
// the ScriptInput. The Service is the only constructor of HostCallbacks; the
// runner just carries it into the run context.
func hostCallbacksFromInput(in ScriptInput) *HostCallbacks {
	if in.hostCallbacks != nil {
		return in.hostCallbacks
	}
	// A bare ScriptInput (e.g. a direct runner test) still needs a trace sink.
	return &HostCallbacks{Grants: map[string]bool{}, trace: &traceSink{}}
}
