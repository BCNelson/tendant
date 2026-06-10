package embedding_test

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/bcnelson/tendant/services/api/internal/embedding"
)

func strptr(s string) *string { return &s }

func TestCategoryText(t *testing.T) {
	cases := []struct {
		name  string
		key   string
		label string
		desc  *string
		want  string
	}{
		{"key only", "communication/email", "", nil, "communication/email"},
		{"key+label", "communication/email", "Email", nil, "communication/email — Email"},
		{"key+label+desc", "x", "Label", strptr("A desc"), "x — Label. A desc"},
		{"empty desc skipped", "x", "Label", strptr(""), "x — Label"},
		{"label empty desc set", "x", "", strptr("D"), "x. D"},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			require.Equal(t, c.want, embedding.CategoryText(c.key, c.label, c.desc))
		})
	}
}

func TestConfigHash(t *testing.T) {
	a := embedding.Config{Provider: "openai", Model: "m1", BaseURL: "u", Dimension: 768}
	require.Equal(t, embedding.ConfigHash(a), embedding.ConfigHash(a), "deterministic")

	// Each field participates in the hash.
	require.NotEqual(t, embedding.ConfigHash(a), embedding.ConfigHash(embedding.Config{Provider: "openai", Model: "m2", BaseURL: "u", Dimension: 768}))
	require.NotEqual(t, embedding.ConfigHash(a), embedding.ConfigHash(embedding.Config{Provider: "ollama", Model: "m1", BaseURL: "u", Dimension: 768}))
	require.NotEqual(t, embedding.ConfigHash(a), embedding.ConfigHash(embedding.Config{Provider: "openai", Model: "m1", BaseURL: "v", Dimension: 768}))
	require.NotEqual(t, embedding.ConfigHash(a), embedding.ConfigHash(embedding.Config{Provider: "openai", Model: "m1", BaseURL: "u", Dimension: 1536}))
}

func TestHashText(t *testing.T) {
	require.Equal(t, embedding.HashText("abc"), embedding.HashText("abc"))
	require.NotEqual(t, embedding.HashText("abc"), embedding.HashText("abd"))
	require.Len(t, embedding.HashText(""), 64) // sha256 hex
}

func TestIdleSlot(t *testing.T) {
	require.Equal(t, embedding.SlotGreen, embedding.IdleSlot(embedding.SlotBlue))
	require.Equal(t, embedding.SlotBlue, embedding.IdleSlot(embedding.SlotGreen))
	require.Equal(t, embedding.SlotBlue, embedding.IdleSlot(""), "no active ⇒ blue")
}

func TestSourceRegistry(t *testing.T) {
	r := &embedding.SourceRegistry{}
	require.Empty(t, r.Sources())
	a := memorySource{typ: "a"}
	b := memorySource{typ: "b"}
	r.Register(a)
	r.Register(b)
	got := r.Sources()
	require.Len(t, got, 2)
	require.Equal(t, "a", got[0].Type())
	require.Equal(t, "b", got[1].Type())
}

func TestEmbedder_AccessorsAndDefaults(t *testing.T) {
	e := embedding.NewEmbedder(embedding.Config{Provider: "openai", Model: "foo", Dimension: 5})
	require.Equal(t, "openai", e.Provider())
	require.Equal(t, "foo", e.Model())
	require.Equal(t, 5, e.Dimension())

	// Default model when unset.
	require.Equal(t, "text-embedding-3-small", embedding.NewEmbedder(embedding.Config{Provider: "openai"}).Model())

	// Unknown provider falls through to the OpenAI-compatible client.
	unknown := embedding.NewEmbedder(embedding.Config{Provider: "some-future-thing"})
	require.NotNil(t, unknown)
	require.Equal(t, "openai", unknown.Provider())
}

// memorySource (defined in reindex_test.go) is also used here; assert it satisfies Source.
var _ embedding.Source = memorySource{}
