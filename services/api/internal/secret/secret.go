// Package secret resolves possibly-sensitive configuration values from the
// environment or from files, so secrets can be delivered via systemd
// LoadCredential / Docker / k8s without landing in the process's literal env.
package secret

import (
	"os"
	"path/filepath"
	"strings"
)

// Getenv resolves name with this precedence (first non-empty wins):
//
//  1. $NAME                        — a literal value in the environment
//  2. file at $NAME_FILE           — its contents (whitespace-trimmed)
//  3. $CREDENTIALS_DIRECTORY/NAME  — a systemd LoadCredential drop
//
// It returns "" when none are present. File contents are trimmed of surrounding
// whitespace (handles the trailing newline editors and `echo` add).
func Getenv(name string) string {
	if v := os.Getenv(name); v != "" {
		return v
	}
	if p := os.Getenv(name + "_FILE"); p != "" {
		if b, err := os.ReadFile(p); err == nil {
			return strings.TrimSpace(string(b))
		}
	}
	if dir := os.Getenv("CREDENTIALS_DIRECTORY"); dir != "" {
		if b, err := os.ReadFile(filepath.Join(dir, name)); err == nil {
			return strings.TrimSpace(string(b))
		}
	}
	return ""
}
