package gatescript

import (
	"testing"

	"github.com/stretchr/testify/require"
)

// wasm_inspect_test.go deepens coverage of the defensive WASM walker — the
// load-bearing static-validation surface. It exercises every import-descriptor
// kind (so skipImportDesc lands correctly on the next import), LEB128 edge
// cases, section skipping/ordering, and adversarial inputs (garbage counts,
// truncation) that must error rather than panic or hang.

// impEntry encodes one import: name(module) + name(field) + descriptor.
func impEntry(module, field string, desc []byte) []byte {
	return concat(name(module), name(field), desc)
}

// importDescriptors, one per external kind.
var (
	descFunc      = concat([]byte{0x00}, uLEB(0))        // func, typeidx 0
	descTable     = []byte{0x01, 0x70, 0x00, 0x01}       // funcref, limits{min1}
	descTableMax  = []byte{0x01, 0x70, 0x01, 0x01, 0x10} // funcref, limits{min1,max16}
	descMem       = []byte{0x02, 0x00, 0x01}             // limits{min1}
	descMemMax    = []byte{0x02, 0x01, 0x01, 0x10}       // limits{min1,max16}
	descGlobalI32 = []byte{0x03, 0x7F, 0x00}             // i32, immutable
	descGlobalMut = []byte{0x03, 0x7E, 0x01}             // i64, mutable
)

func TestInspect_AllImportKindsSkippedCorrectly(t *testing.T) {
	// A function import sits LAST, behind one import of every other kind. The
	// walker only lands on it with the right (module,name) if it skipped each
	// preceding descriptor exactly.
	body := concat(
		impEntry("env", "tbl", descTable),
		impEntry("env", "tblmax", descTableMax),
		impEntry("env", "mem", descMem),
		impEntry("env", "memmax", descMemMax),
		impEntry("env", "g", descGlobalI32),
		impEntry("env", "gm", descGlobalMut),
		impEntry("tendant", "contacts.isKnown", descFunc),
	)
	mod := concat(moduleHeader, sec(2, vec(7, body)))

	shape, err := Inspect(mod)
	require.NoError(t, err)
	require.Len(t, shape.Imports, 7)

	last := shape.Imports[6]
	require.Equal(t, "tendant", last.Module)
	require.Equal(t, "contacts.isKnown", last.Name)
	require.Equal(t, extFunc, last.Kind)

	require.Equal(t, extTable, shape.Imports[0].Kind)
	require.Equal(t, extMem, shape.Imports[2].Kind)
	require.Equal(t, extGlobal, shape.Imports[4].Kind)
}

func TestInspect_MultiByteLEB128Name(t *testing.T) {
	// A 200-char name forces a 2-byte LEB128 length (200 = 0xC8 0x01).
	longName := ""
	for i := 0; i < 200; i++ {
		longName += "a"
	}
	body := impEntry("tendant", longName, descFunc)
	mod := concat(moduleHeader, sec(2, vec(1, body)))
	shape, err := Inspect(mod)
	require.NoError(t, err)
	require.Len(t, shape.Imports, 1)
	require.Equal(t, longName, shape.Imports[0].Name)
	require.Len(t, shape.Imports[0].Name, 200)
}

func TestInspect_CustomAndUnknownSectionsSkipped(t *testing.T) {
	// A custom section (id 0) and an unknown high-id section between the real
	// import + export sections must be skipped by their declared size.
	custom := sec(0, concat(name("producers"), []byte{0xDE, 0xAD, 0xBE, 0xEF}))
	importSec := sec(2, vec(1, impEntry("tendant", "log", descFunc)))
	exportSec := sec(7, vec(1, concat(name("evaluate"), []byte{0x00}, uLEB(0))))
	highSec := sec(100, []byte{0x01, 0x02, 0x03}) // unknown section id

	mod := concat(moduleHeader, custom, importSec, highSec, exportSec)
	shape, err := Inspect(mod)
	require.NoError(t, err)
	require.Len(t, shape.Imports, 1)
	require.Equal(t, "log", shape.Imports[0].Name)
	require.Len(t, shape.Exports, 1)
	require.Equal(t, "evaluate", shape.Exports[0].Name)
}

func TestInspect_ExportKinds(t *testing.T) {
	// memory/table/global exports parse with their kinds; only func exports get
	// names the validator cares about.
	exports := concat(
		name("memory"), []byte{0x02, 0x00},
		name("evaluate"), []byte{0x00}, uLEB(7),
		name("g"), []byte{0x03}, uLEB(0),
	)
	mod := concat(moduleHeader, sec(7, vec(3, exports)))
	shape, err := Inspect(mod)
	require.NoError(t, err)
	require.Len(t, shape.Exports, 3)
	kinds := map[string]byte{}
	for _, e := range shape.Exports {
		kinds[e.Name] = e.Kind
	}
	require.Equal(t, extMem, kinds["memory"])
	require.Equal(t, extFunc, kinds["evaluate"])
	require.Equal(t, extGlobal, kinds["g"])
}

func TestInspect_AdversarialInputsErrorNotPanic(t *testing.T) {
	cases := []struct {
		name string
		in   []byte
	}{
		{
			// import section declares a huge vector count but provides no entries
			name: "oversized import vector count",
			in:   concat(moduleHeader, sec(2, append(uLEB(1_000_000), 0x00))),
		},
		{
			// a name claims more bytes than remain
			name: "truncated name length",
			in:   concat(moduleHeader, sec(2, concat(uLEB(1), uLEB(250)))),
		},
		{
			// unknown import kind byte
			name: "unknown import kind",
			in:   concat(moduleHeader, sec(2, vec(1, concat(name("env"), name("x"), []byte{0x09})))),
		},
		{
			// 6-byte LEB128 (overflows u32)
			name: "leb128 overflow in section size",
			in:   concat(moduleHeader, []byte{0x02, 0x80, 0x80, 0x80, 0x80, 0x80, 0x01}),
		},
		{
			// section claims more body than the module holds
			name: "section size beyond module",
			in:   concat(moduleHeader, []byte{0x02, 0x7F}),
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			require.NotPanics(t, func() {
				_, err := Inspect(tc.in)
				require.Error(t, err)
			})
		})
	}
}
