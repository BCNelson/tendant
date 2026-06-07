package gatescript

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/bcnelson/tendant/services/api/internal/gatescript/ascsdk"
)

// asc_subprocess.go is an OPT-IN Tier-1 server-compile backend that shells out
// to the `asc` (AssemblyScript) binary. It is NOT the principle-IX-ideal: the
// compiler runs as a host subprocess, not inside the wazero sandbox that the
// gate scripts themselves run in. The sandboxed asc-on-QuickJS-on-wazero backend
// (internal/gatescript/asc/, pending vendored binaries) remains the
// production-hardening target. This backend is therefore activated only when an
// operator explicitly sets TENDANT_ASC_BACKEND=subprocess AND `asc` is on PATH
// (e.g. the devenv shell ships it). The default build keeps Tier-1 server
// compile at COMPILE_FAILED; Tier-2 BYO `.wasm` is unaffected.
//
// Compile strategy (proven robust): write the vendored SDK to a temp build dir
// as `tendant_gate_sdk/{index,abi}.ts`, rewrite the author's
// "@tendant/gate-sdk" specifier to the relative SDK path, ensure the ABI
// memory-management functions are re-exported by the entry, then run asc with a
// timeout. Relative resolution yields clean exports (only evaluate +
// tendant_alloc/tendant_dealloc + memory), so the output passes static
// validation unchanged.

// SubprocessASCCompiler compiles AssemblyScript via the `asc` binary.
type SubprocessASCCompiler struct {
	AscPath      string
	MaxCompileMs int
}

// NewSubprocessASCCompiler locates `asc` on PATH. Returns ErrASCUnavailable when
// it is not installed.
func NewSubprocessASCCompiler() (*SubprocessASCCompiler, error) {
	p, err := exec.LookPath("asc")
	if err != nil {
		return nil, ErrASCUnavailable
	}
	return &SubprocessASCCompiler{AscPath: p, MaxCompileMs: CeilingsFromEnv().ASCMaxCompileMs}, nil
}

const sdkRelImport = `"./tendant_gate_sdk/index"`

// Compile implements the ascCompiler signature wired via SetASCCompiler.
func (c *SubprocessASCCompiler) Compile(ctx context.Context, source string) ([]byte, []Diag, error) {
	dir, err := os.MkdirTemp("", "tendant-asc-")
	if err != nil {
		return nil, nil, fmt.Errorf("asc: temp dir: %w", err)
	}
	defer os.RemoveAll(dir)

	// Materialize the vendored SDK as a relative sibling module.
	sdkDir := filepath.Join(dir, "tendant_gate_sdk")
	if err := os.MkdirAll(sdkDir, 0o700); err != nil {
		return nil, nil, fmt.Errorf("asc: sdk dir: %w", err)
	}
	for name, content := range ascsdk.Files() {
		if err := os.WriteFile(filepath.Join(sdkDir, name), content, 0o600); err != nil {
			return nil, nil, fmt.Errorf("asc: write sdk %s: %w", name, err)
		}
	}

	// Rewrite the author's SDK import to the relative path, and ensure the ABI
	// memory-management functions are exported by the entry (asc only emits the
	// entry's exports; the host needs tendant_alloc for call.get()/etc.).
	src := strings.ReplaceAll(source, `"@tendant/gate-sdk"`, sdkRelImport)
	if !strings.Contains(src, "tendant_alloc") {
		src += "\nexport { tendant_alloc, tendant_dealloc } from " + sdkRelImport + ";\n"
	}
	if err := os.WriteFile(filepath.Join(dir, "gate.ts"), []byte(src), 0o600); err != nil {
		return nil, nil, fmt.Errorf("asc: write source: %w", err)
	}

	maxMs := c.MaxCompileMs
	if maxMs <= 0 {
		maxMs = 5000
	}
	cctx, cancel := context.WithTimeout(ctx, time.Duration(maxMs)*time.Millisecond)
	defer cancel()

	outPath := filepath.Join(dir, "out.wasm")
	cmd := exec.CommandContext(cctx, c.AscPath,
		"gate.ts", "--target", "release", "--use", "abort=", "--use", "Date.now=", "-o", outPath)
	cmd.Dir = dir
	var stderr bytes.Buffer
	cmd.Stderr = &stderr
	runErr := cmd.Run()

	diags := parseAscDiagnostics(stderr.String())
	if cctx.Err() == context.DeadlineExceeded {
		return nil, diags, fmt.Errorf("asc compile exceeded %d ms (sandbox_timeout)", maxMs)
	}
	if runErr != nil {
		return nil, diags, fmt.Errorf("asc compile failed: %s", firstError(diags, stderr.String()))
	}
	wasm, rerr := os.ReadFile(outPath)
	if rerr != nil || len(wasm) == 0 {
		return nil, diags, errors.New("asc produced no output")
	}
	return wasm, diags, nil
}

// ascDiagRe matches asc diagnostic lines like
// "ERROR TS2305: ... in gate.ts(6,10)" / "WARNING AS235: ...".
var ascDiagRe = regexp.MustCompile(`(?m)^(ERROR|WARNING)\s+([A-Z]+\d+):\s*(.*)$`)
var ascLocRe = regexp.MustCompile(`in\s+(\S+?)\((\d+),(\d+)\)`)

func parseAscDiagnostics(stderr string) []Diag {
	var diags []Diag
	for _, m := range ascDiagRe.FindAllStringSubmatch(stderr, -1) {
		severity := "error"
		if m[1] == "WARNING" {
			severity = "warning"
		}
		d := Diag{Severity: severity, Msg: strings.TrimSpace(m[2] + ": " + m[3])}
		if loc := ascLocRe.FindStringSubmatch(stderr); loc != nil {
			d.File = loc[1]
			d.Line, _ = strconv.Atoi(loc[2])
			d.Col, _ = strconv.Atoi(loc[3])
		}
		diags = append(diags, d)
	}
	return diags
}

func firstError(diags []Diag, fallback string) string {
	for _, d := range diags {
		if d.Severity == "error" {
			return d.Msg
		}
	}
	if fallback != "" {
		return strings.TrimSpace(fallback)
	}
	return "unknown compile error"
}
