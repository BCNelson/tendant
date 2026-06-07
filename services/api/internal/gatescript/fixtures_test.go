package gatescript

// fixtures_test.go hand-encodes minimal WASM modules implementing the v1 gate-
// script ABI. No WASM compiler (asc/cargo/wat2wasm) is available in CI, so the
// runner is verified against these byte-built fixtures.
//
// Every fixture exports: memory, tendant_alloc(i32)->i32 (bump allocator),
// tendant_dealloc(i32,i32)->(), and evaluate()->i64. The verdict JSON (when
// present) is placed at offset verdictOffset via a data segment; evaluate
// returns the packed (verdictOffset<<32 | len).

const (
	verdictOffset = 1024 // JSON verdict region (data segment)
	allocBase     = 4096 // tendant_alloc bump base (above the verdict region)
)

// --- LEB128 encoders --------------------------------------------------------

func uLEB(n uint64) []byte {
	var out []byte
	for {
		b := byte(n & 0x7F)
		n >>= 7
		if n != 0 {
			out = append(out, b|0x80)
		} else {
			out = append(out, b)
			return out
		}
	}
}

func sLEB(v int64) []byte {
	var out []byte
	for {
		b := byte(v & 0x7F)
		v >>= 7
		signBit := b & 0x40
		if (v == 0 && signBit == 0) || (v == -1 && signBit != 0) {
			out = append(out, b)
			return out
		}
		out = append(out, b|0x80)
	}
}

func vec(count int, body []byte) []byte { return append(uLEB(uint64(count)), body...) }

func sec(id byte, body []byte) []byte {
	return append(append([]byte{id}, uLEB(uint64(len(body)))...), body...)
}

func name(s string) []byte { return append(uLEB(uint64(len(s))), []byte(s)...) }

var moduleHeader = []byte{0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00}

// commonSections returns the type/function/memory/export sections shared by all
// fixtures. evaluate=func0 (()->i64), tendant_alloc=func1 ((i32)->i32),
// tendant_dealloc=func2 ((i32,i32)->()).
func commonSections() []byte {
	// Type section: three function types.
	t0 := []byte{0x60, 0x00, 0x01, 0x7E}       // () -> i64
	t1 := []byte{0x60, 0x01, 0x7F, 0x01, 0x7F} // (i32) -> i32
	t2 := []byte{0x60, 0x02, 0x7F, 0x7F, 0x00} // (i32,i32) -> ()
	typeSec := sec(1, vec(3, concat(t0, t1, t2)))

	// Function section: func0->type0, func1->type1, func2->type2.
	funcSec := sec(3, vec(3, []byte{0x00, 0x01, 0x02}))

	// Memory section: one memory, min 1 page, no max.
	memSec := sec(5, vec(1, []byte{0x00, 0x01}))

	// Export section.
	exports := concat(
		name("memory"), []byte{0x02, 0x00},
		name("evaluate"), []byte{0x00, 0x00},
		name("tendant_alloc"), []byte{0x00, 0x01},
		name("tendant_dealloc"), []byte{0x00, 0x02},
	)
	exportSec := sec(7, vec(4, exports))

	return concat(typeSec, funcSec, memSec, exportSec)
}

// allocAndDeallocBodies returns the code bodies for tendant_alloc (returns a
// constant bump pointer) and tendant_dealloc (no-op).
func allocBody() []byte {
	// locals: 0; body: i32.const allocBase; end
	body := concat([]byte{0x00}, []byte{0x41}, sLEB(allocBase), []byte{0x0B})
	return append(uLEB(uint64(len(body))), body...)
}

func deallocBody() []byte {
	// locals: 0; body: end
	body := []byte{0x00, 0x0B}
	return append(uLEB(uint64(len(body))), body...)
}

// buildStaticVerdictModule returns a module whose evaluate() returns a pointer
// to verdictJSON stored in a data segment at verdictOffset.
func buildStaticVerdictModule(verdictJSON string) []byte {
	data := []byte(verdictJSON)
	packed := (int64(verdictOffset) << 32) | int64(len(data))

	// evaluate body: i64.const packed; end
	evalInner := concat([]byte{0x00}, []byte{0x42}, sLEB(packed), []byte{0x0B})
	evalBody := append(uLEB(uint64(len(evalInner))), evalInner...)
	codeSec := sec(10, vec(3, concat(evalBody, allocBody(), deallocBody())))

	// Data section: active segment, mem 0, offset i32.const verdictOffset.
	offsetExpr := concat([]byte{0x41}, sLEB(verdictOffset), []byte{0x0B})
	segment := concat([]byte{0x00}, offsetExpr, uLEB(uint64(len(data))), data)
	dataSec := sec(11, vec(1, segment))

	return concat(moduleHeader, commonSections(), codeSec, dataSec)
}

// buildTrapModule returns a module whose evaluate() executes `unreachable`.
func buildTrapModule() []byte {
	// evaluate body: unreachable (0x00); end. (No i64 produced — traps first.)
	evalInner := []byte{0x00, 0x00, 0x0B} // locals=0; unreachable; end
	evalBody := append(uLEB(uint64(len(evalInner))), evalInner...)
	codeSec := sec(10, vec(3, concat(evalBody, allocBody(), deallocBody())))
	return concat(moduleHeader, commonSections(), codeSec)
}

// buildLoopModule returns a module whose evaluate() spins forever:
//
//	(loop $l br $l end)  — interruptible only via context cancellation.
func buildLoopModule() []byte {
	// locals=0; block: loop(void 0x40) { br 0 } end; unreachable; end
	// 0x03 0x40 = loop with empty blocktype; 0x0C 0x00 = br 0; 0x0B = end loop;
	// 0x00 = unreachable (never reached); 0x0B = end function.
	evalInner := []byte{0x00, 0x03, 0x40, 0x0C, 0x00, 0x0B, 0x00, 0x0B}
	evalBody := append(uLEB(uint64(len(evalInner))), evalInner...)
	codeSec := sec(10, vec(3, concat(evalBody, allocBody(), deallocBody())))
	return concat(moduleHeader, commonSections(), codeSec)
}

func concat(parts ...[]byte) []byte {
	var out []byte
	for _, p := range parts {
		out = append(out, p...)
	}
	return out
}
