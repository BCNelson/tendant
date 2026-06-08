package config

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestInterpolate_String(t *testing.T) {
	dir := t.TempDir()
	secretFile := filepath.Join(dir, "sec")
	if err := os.WriteFile(secretFile, []byte("file-val\n"), 0o600); err != nil {
		t.Fatal(err)
	}
	relFile := filepath.Join(dir, "rel")
	if err := os.WriteFile(relFile, []byte("rel-val"), 0o600); err != nil {
		t.Fatal(err)
	}
	t.Setenv("IP_VAR", "env-val")
	t.Setenv("IP_PATHVAR", secretFile)

	cases := []struct {
		name string
		in   string
		want string
	}{
		{"plain passthrough", "no tokens here", "no tokens here"},
		{"env", "${env:IP_VAR}", "env-val"},
		{"env with surrounding text", "a-${env:IP_VAR}-b", "a-env-val-b"},
		{"env default used", "${env:IP_MISSING:-fallback}", "fallback"},
		{"env default ignored when set", "${env:IP_VAR:-fallback}", "env-val"},
		{"file absolute", "${file:" + secretFile + "}", "file-val"},
		{"file relative to config dir", "${file:rel}", "rel-val"},
		{"nested file-of-env", "${file:${env:IP_PATHVAR}}", "file-val"},
		{"dollar escape", "literal $$ sign", "literal $ sign"},
		{"price with dollars", "costs $$5 and $$10", "costs $5 and $10"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got, err := resolveString(tc.in, dir)
			if err != nil {
				t.Fatalf("resolveString(%q): %v", tc.in, err)
			}
			if got != tc.want {
				t.Fatalf("resolveString(%q) = %q, want %q", tc.in, got, tc.want)
			}
		})
	}
}

func TestInterpolate_Errors(t *testing.T) {
	dir := t.TempDir()
	cases := []struct {
		name string
		in   string
	}{
		{"unset env no default", "${env:IP_DEFINITELY_UNSET}"},
		{"missing file", "${file:" + filepath.Join(dir, "nope") + "}"},
		{"unterminated", "${env:FOO"},
		{"unknown scheme survives to error", "${bogus:x}"},
		{"empty env name", "${env:}"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if _, err := resolveString(tc.in, dir); err == nil {
				t.Fatalf("resolveString(%q) expected error", tc.in)
			}
		})
	}
}

func TestInterpolate_WalksContainers(t *testing.T) {
	t.Setenv("IP_NESTED", "deep")
	tree := map[string]any{
		"a": "${env:IP_NESTED}",
		"b": []any{
			map[string]any{"k": "${env:IP_NESTED}"},
			"plain",
			int64(7),
		},
		"c": int64(42),
	}
	out, err := interpolate(tree, "")
	if err != nil {
		t.Fatal(err)
	}
	m := out.(map[string]any)
	if m["a"] != "deep" {
		t.Fatalf("a = %v", m["a"])
	}
	if m["c"] != int64(42) {
		t.Fatalf("non-string mangled: c = %v", m["c"])
	}
	b := m["b"].([]any)
	if b[0].(map[string]any)["k"] != "deep" {
		t.Fatalf("nested map not interpolated: %v", b[0])
	}
	if b[1] != "plain" || b[2] != int64(7) {
		t.Fatalf("slice scalars mangled: %v", b)
	}
}

func TestExpandFile_TrimsTrailingOnly(t *testing.T) {
	dir := t.TempDir()
	p := filepath.Join(dir, "k")
	if err := os.WriteFile(p, []byte("  leading-kept\ttrailing-trimmed\n\n"), 0o600); err != nil {
		t.Fatal(err)
	}
	got, err := expandFile(p, dir)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.HasPrefix(got, "  leading-kept") {
		t.Fatalf("leading whitespace should be preserved: %q", got)
	}
	if strings.HasSuffix(got, "\n") || strings.HasSuffix(got, "trimmed ") {
		t.Fatalf("trailing whitespace should be trimmed: %q", got)
	}
}
