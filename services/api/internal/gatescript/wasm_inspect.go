package gatescript

import (
	"errors"
	"fmt"
)

// wasm_inspect.go is a pure-Go, defensive walker over a WebAssembly module's
// import (id 2) and export (id 7) sections. It is the load-bearing safety
// property of Phase 5: the static-validation pipeline rejects a module whose
// imports are not covered by its manifest, BEFORE the module is ever
// instantiated. There is no runtime check behind this — if the walker has a
// bypass, the no-egress guarantee becomes a wish.
//
// Parsing is bounded and allocation-safe: every read is length-checked, LEB128
// decoding is overflow-guarded, vector elements are appended (never
// pre-allocated from an attacker-controlled count), and each section is parsed
// within its declared bounds. Malformed input always yields an error — never a
// panic, never a trap of the host. (Fuzzed in wasm_inspect_fuzz_test.go.)

// WASM external kinds (import/export descriptor tags).
const (
	extFunc   byte = 0x00
	extTable  byte = 0x01
	extMem    byte = 0x02
	extGlobal byte = 0x03
)

// Import is one entry of the WASM import section.
type Import struct {
	Module string
	Name   string
	Kind   byte // ext* above
}

// Export is one entry of the WASM export section.
type Export struct {
	Name string
	Kind byte // ext* above
}

// ModuleShape is the subset of a WASM module the static validator needs.
type ModuleShape struct {
	Imports []Import
	Exports []Export
}

var (
	errBadMagic    = errors.New("wasm: bad magic (not a WebAssembly module)")
	errBadVersion  = errors.New("wasm: unsupported binary version")
	errTruncated   = errors.New("wasm: truncated module")
	errLEBOverflow = errors.New("wasm: LEB128 overflow")
)

// InspectImports returns the import section entries (FR-010).
func InspectImports(wasm []byte) ([]Import, error) {
	shape, err := Inspect(wasm)
	if err != nil {
		return nil, err
	}
	return shape.Imports, nil
}

// InspectExports returns the export section entries (FR-011).
func InspectExports(wasm []byte) ([]Export, error) {
	shape, err := Inspect(wasm)
	if err != nil {
		return nil, err
	}
	return shape.Exports, nil
}

// Inspect walks the module header and the import + export sections in one pass.
// All other sections are skipped by their declared size without being decoded.
func Inspect(wasm []byte) (*ModuleShape, error) {
	r := &reader{data: wasm}

	// Header: magic (\0asm) + version (1, little-endian u32).
	magic, err := r.readN(4)
	if err != nil {
		return nil, errBadMagic
	}
	if magic[0] != 0x00 || magic[1] != 0x61 || magic[2] != 0x73 || magic[3] != 0x6D {
		return nil, errBadMagic
	}
	version, err := r.readN(4)
	if err != nil {
		return nil, errBadVersion
	}
	if version[0] != 0x01 || version[1] != 0x00 || version[2] != 0x00 || version[3] != 0x00 {
		return nil, errBadVersion
	}

	shape := &ModuleShape{}
	for r.remaining() > 0 {
		id, err := r.readByte()
		if err != nil {
			return nil, err
		}
		size, err := r.readVarU32()
		if err != nil {
			return nil, err
		}
		body, err := r.readN(int(size))
		if err != nil {
			return nil, fmt.Errorf("wasm: section %d body: %w", id, err)
		}
		switch id {
		case 2: // import section
			imports, err := parseImports(body)
			if err != nil {
				return nil, err
			}
			shape.Imports = imports
		case 7: // export section
			exports, err := parseExports(body)
			if err != nil {
				return nil, err
			}
			shape.Exports = exports
		default:
			// Skip every other section (custom/type/func/table/mem/global/
			// start/element/code/data/datacount) without decoding it.
		}
	}
	return shape, nil
}

func parseImports(body []byte) ([]Import, error) {
	r := &reader{data: body}
	count, err := r.readVarU32()
	if err != nil {
		return nil, err
	}
	imports := make([]Import, 0)
	for i := uint32(0); i < count; i++ {
		mod, err := r.readName()
		if err != nil {
			return nil, err
		}
		name, err := r.readName()
		if err != nil {
			return nil, err
		}
		kind, err := r.readByte()
		if err != nil {
			return nil, err
		}
		if err := skipImportDesc(r, kind); err != nil {
			return nil, err
		}
		imports = append(imports, Import{Module: mod, Name: name, Kind: kind})
	}
	return imports, nil
}

// skipImportDesc advances past the type-specific descriptor following an
// import's (module, name, kind) so the loop lands on the next import.
func skipImportDesc(r *reader, kind byte) error {
	switch kind {
	case extFunc:
		_, err := r.readVarU32() // typeidx
		return err
	case extTable:
		if _, err := r.readByte(); err != nil { // element type (reftype)
			return err
		}
		return r.skipLimits()
	case extMem:
		return r.skipLimits()
	case extGlobal:
		if _, err := r.readByte(); err != nil { // valtype
			return err
		}
		_, err := r.readByte() // mutability
		return err
	default:
		return fmt.Errorf("wasm: unknown import kind 0x%02x", kind)
	}
}

func parseExports(body []byte) ([]Export, error) {
	r := &reader{data: body}
	count, err := r.readVarU32()
	if err != nil {
		return nil, err
	}
	exports := make([]Export, 0)
	for i := uint32(0); i < count; i++ {
		name, err := r.readName()
		if err != nil {
			return nil, err
		}
		kind, err := r.readByte()
		if err != nil {
			return nil, err
		}
		if _, err := r.readVarU32(); err != nil { // export index
			return nil, err
		}
		exports = append(exports, Export{Name: name, Kind: kind})
	}
	return exports, nil
}

// reader is a bounded cursor over a byte slice. Every accessor checks bounds.
type reader struct {
	data []byte
	pos  int
}

func (r *reader) remaining() int { return len(r.data) - r.pos }

func (r *reader) readByte() (byte, error) {
	if r.pos >= len(r.data) {
		return 0, errTruncated
	}
	b := r.data[r.pos]
	r.pos++
	return b, nil
}

func (r *reader) readN(n int) ([]byte, error) {
	if n < 0 || r.remaining() < n {
		return nil, errTruncated
	}
	out := r.data[r.pos : r.pos+n]
	r.pos += n
	return out, nil
}

// readVarU32 decodes an unsigned LEB128 u32, guarding against overflow and
// over-long encodings (max 5 bytes for 32 bits).
func (r *reader) readVarU32() (uint32, error) {
	var result uint32
	var shift uint
	for i := 0; i < 5; i++ {
		b, err := r.readByte()
		if err != nil {
			return 0, err
		}
		if shift == 28 && b > 0x0F {
			return 0, errLEBOverflow
		}
		result |= uint32(b&0x7F) << shift
		if b&0x80 == 0 {
			return result, nil
		}
		shift += 7
	}
	return 0, errLEBOverflow
}

// readName reads a length-prefixed UTF-8 name. The length is bounded by the
// remaining bytes, so an attacker-controlled length cannot force a large alloc.
func (r *reader) readName() (string, error) {
	n, err := r.readVarU32()
	if err != nil {
		return "", err
	}
	b, err := r.readN(int(n))
	if err != nil {
		return "", err
	}
	return string(b), nil
}

// skipLimits advances past a WASM limits structure (flag byte + min, optional
// max), used inside table/memory import descriptors.
func (r *reader) skipLimits() error {
	flag, err := r.readByte()
	if err != nil {
		return err
	}
	if _, err := r.readVarU32(); err != nil { // min
		return err
	}
	if flag != 0x00 { // has-max
		if _, err := r.readVarU32(); err != nil { // max
			return err
		}
	}
	return nil
}
