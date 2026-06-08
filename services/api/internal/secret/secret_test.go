package secret

import (
	"os"
	"path/filepath"
	"testing"
)

func TestGetenv(t *testing.T) {
	t.Run("literal env wins", func(t *testing.T) {
		t.Setenv("TENDANT_X", "literal")
		// _FILE and CREDENTIALS_DIRECTORY are also set, but the literal takes precedence.
		dir := t.TempDir()
		writeFile(t, filepath.Join(dir, "fromfile"), "file-value\n")
		t.Setenv("TENDANT_X_FILE", filepath.Join(dir, "fromfile"))
		t.Setenv("CREDENTIALS_DIRECTORY", dir)
		writeFile(t, filepath.Join(dir, "TENDANT_X"), "cred-value\n")

		if got := Getenv("TENDANT_X"); got != "literal" {
			t.Fatalf("got %q, want %q", got, "literal")
		}
	})

	t.Run("reads _FILE and trims whitespace", func(t *testing.T) {
		dir := t.TempDir()
		path := filepath.Join(dir, "secret")
		writeFile(t, path, "  file-value\n")
		t.Setenv("TENDANT_X_FILE", path)

		if got := Getenv("TENDANT_X"); got != "file-value" {
			t.Fatalf("got %q, want %q", got, "file-value")
		}
	})

	t.Run("reads CREDENTIALS_DIRECTORY drop and trims", func(t *testing.T) {
		dir := t.TempDir()
		writeFile(t, filepath.Join(dir, "TENDANT_X"), "cred-value\n")
		t.Setenv("CREDENTIALS_DIRECTORY", dir)

		if got := Getenv("TENDANT_X"); got != "cred-value" {
			t.Fatalf("got %q, want %q", got, "cred-value")
		}
	})

	t.Run("_FILE wins over CREDENTIALS_DIRECTORY", func(t *testing.T) {
		dir := t.TempDir()
		filePath := filepath.Join(dir, "fromfile")
		writeFile(t, filePath, "file-value")
		writeFile(t, filepath.Join(dir, "TENDANT_X"), "cred-value")
		t.Setenv("TENDANT_X_FILE", filePath)
		t.Setenv("CREDENTIALS_DIRECTORY", dir)

		if got := Getenv("TENDANT_X"); got != "file-value" {
			t.Fatalf("got %q, want %q", got, "file-value")
		}
	})

	t.Run("missing everywhere returns empty", func(t *testing.T) {
		if got := Getenv("TENDANT_DEFINITELY_UNSET"); got != "" {
			t.Fatalf("got %q, want empty", got)
		}
	})

	t.Run("unreadable _FILE falls through to credentials dir", func(t *testing.T) {
		dir := t.TempDir()
		t.Setenv("TENDANT_X_FILE", filepath.Join(dir, "does-not-exist"))
		writeFile(t, filepath.Join(dir, "TENDANT_X"), "cred-value")
		t.Setenv("CREDENTIALS_DIRECTORY", dir)

		if got := Getenv("TENDANT_X"); got != "cred-value" {
			t.Fatalf("got %q, want %q", got, "cred-value")
		}
	})
}

func writeFile(t *testing.T, path, content string) {
	t.Helper()
	if err := os.WriteFile(path, []byte(content), 0o600); err != nil {
		t.Fatalf("write %s: %v", path, err)
	}
}
