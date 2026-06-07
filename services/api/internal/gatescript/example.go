package gatescript

// example.go ships a tiny, runnable, dependency-free gate-script module in
// production code (no WASM toolchain required). It is used by the optional
// example seeder (TENDANT_SEED_EXAMPLE_GATE_SCRIPT) and by integration tests
// that need a real module the WazeroRunner can execute. The module exports the
// ABI-required {memory, tendant_alloc, tendant_dealloc, evaluate} and imports
// nothing, so it passes static validation with an empty `reads` set.
//
// evaluate() returns the constant verdict JSON placed in a data segment — it is
// the "approve-everything" example (useful for the floor-supremacy demo and the
// happy-path e2e). The encoder below is the same minimal WASM byte-builder used
// by the test fixtures, kept here so non-test code can mint the bytes.

const exampleVerdictOffset = 1024
const exampleAllocBase = 4096

// ExampleApproveModule returns a runnable module whose evaluate() returns
// {"decision":"approve",...}.
func ExampleApproveModule() []byte {
	return buildApproveModule(`{"decision":"approve","evidence":{"summary":"example: approve","considered_fields":[]}}`)
}

// ExampleRequestDecisionModule returns a runnable module whose evaluate()
// returns {"decision":"request_decision",...} — useful for exercising the
// script→ApprovalRequest path (and the decision↔evaluation audit link).
func ExampleRequestDecisionModule() []byte {
	return buildApproveModule(`{"decision":"request_decision","evidence":{"summary":"example: ask the owner","considered_fields":["payload.to"]}}`)
}

// ExampleManifest is the manifest for the example module: no reads (it imports
// no host functions), tool pinned to the caller-supplied global_uri.
func ExampleManifest(toolGlobalURI string) Manifest {
	return Manifest{
		ManifestVersion: "1",
		Tool:            toolGlobalURI,
		Entrypoint:      "evaluate",
		Reads:           []string{},
		Egress:          []string{},
		Limits:          ManifestLimits{TimeoutMs: 250, MemoryPages: 64},
	}
}

// --- minimal WASM encoder (mirrors fixtures_test.go) ------------------------

func exULEB(n uint64) []byte {
	var out []byte
	for {
		b := byte(n & 0x7F)
		n >>= 7
		if n != 0 {
			out = append(out, b|0x80)
		} else {
			return append(out, b)
		}
	}
}

func exSLEB(v int64) []byte {
	var out []byte
	for {
		b := byte(v & 0x7F)
		v >>= 7
		sign := b & 0x40
		if (v == 0 && sign == 0) || (v == -1 && sign != 0) {
			return append(out, b)
		}
		out = append(out, b|0x80)
	}
}

func exVec(count int, body []byte) []byte { return append(exULEB(uint64(count)), body...) }
func exSec(id byte, body []byte) []byte {
	return append(append([]byte{id}, exULEB(uint64(len(body)))...), body...)
}
func exName(s string) []byte { return append(exULEB(uint64(len(s))), []byte(s)...) }

func exConcat(parts ...[]byte) []byte {
	var out []byte
	for _, p := range parts {
		out = append(out, p...)
	}
	return out
}

func buildApproveModule(verdictJSON string) []byte {
	header := []byte{0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00}

	t0 := []byte{0x60, 0x00, 0x01, 0x7E}       // () -> i64
	t1 := []byte{0x60, 0x01, 0x7F, 0x01, 0x7F} // (i32) -> i32
	t2 := []byte{0x60, 0x02, 0x7F, 0x7F, 0x00} // (i32,i32) -> ()
	typeSec := exSec(1, exVec(3, exConcat(t0, t1, t2)))
	funcSec := exSec(3, exVec(3, []byte{0x00, 0x01, 0x02}))
	memSec := exSec(5, exVec(1, []byte{0x00, 0x01}))

	exports := exConcat(
		exName("memory"), []byte{0x02, 0x00},
		exName("evaluate"), []byte{0x00, 0x00},
		exName("tendant_alloc"), []byte{0x00, 0x01},
		exName("tendant_dealloc"), []byte{0x00, 0x02},
	)
	exportSec := exSec(7, exVec(4, exports))

	data := []byte(verdictJSON)
	packed := (int64(exampleVerdictOffset) << 32) | int64(len(data))
	evalInner := exConcat([]byte{0x00}, []byte{0x42}, exSLEB(packed), []byte{0x0B})
	evalBody := append(exULEB(uint64(len(evalInner))), evalInner...)
	allocInner := exConcat([]byte{0x00}, []byte{0x41}, exSLEB(exampleAllocBase), []byte{0x0B})
	allocBody := append(exULEB(uint64(len(allocInner))), allocInner...)
	deallocBody := append(exULEB(2), []byte{0x00, 0x0B}...)
	codeSec := exSec(10, exVec(3, exConcat(evalBody, allocBody, deallocBody)))

	offsetExpr := exConcat([]byte{0x41}, exSLEB(exampleVerdictOffset), []byte{0x0B})
	segment := exConcat([]byte{0x00}, offsetExpr, exULEB(uint64(len(data))), data)
	dataSec := exSec(11, exVec(1, segment))

	return exConcat(header, typeSec, funcSec, memSec, exportSec, codeSec, dataSec)
}
