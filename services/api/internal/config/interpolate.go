package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/bcnelson/tendant/services/api/internal/secret"
)

// Interpolation lets any string in the config file reference a secret without
// baking it into the file:
//
//	api_key = "${env:OPENAI_API_KEY}"        # value of the env var
//	api_key = "${file:/run/secrets/openai}"  # contents of the file (trimmed)
//	model   = "${env:MODEL:-gpt-4.1-mini}"   # env var, or the default after :-
//	api_key = "${file:${env:OPENAI_KEY_FILE}}"   # nested: path comes from env
//
// Resolution is two-phase: every ${env:...} is expanded first, then every
// ${file:...}. Env-first means a ${file:...} argument may contain an
// ${env:...} token. `$$` is a literal `$`. Any ${...} that survives both
// phases is an error, so typos fail loudly at boot rather than silently
// shipping an unexpanded token to a provider.
//
// Only values from the config FILE are interpolated — environment- and
// default-sourced values pass through untouched, so a DSN that legitimately
// contains "${" (delivered via env) is never mangled.
//
// ${env:NAME} resolves through secret.Getenv, so it also honors NAME_FILE and
// the systemd CREDENTIALS_DIRECTORY drop, not just the literal env var.

// interpolate walks a decoded config tree and expands interpolation tokens in
// every string leaf. dir is the directory of the config file, used to resolve
// relative ${file:...} paths.
func interpolate(v any, dir string) (any, error) {
	switch x := v.(type) {
	case map[string]any:
		for k, child := range x {
			out, err := interpolate(child, dir)
			if err != nil {
				return nil, err
			}
			x[k] = out
		}
		return x, nil
	case []any:
		for i, child := range x {
			out, err := interpolate(child, dir)
			if err != nil {
				return nil, err
			}
			x[i] = out
		}
		return x, nil
	case []map[string]any:
		for i, child := range x {
			out, err := interpolate(child, dir)
			if err != nil {
				return nil, err
			}
			m, _ := out.(map[string]any)
			x[i] = m
		}
		return x, nil
	case string:
		return resolveString(x, dir)
	default:
		return v, nil
	}
}

// resolveString expands all interpolation tokens in s: ${env:...} first, then
// ${file:...}, then the $$ -> $ unescape. A surviving ${...} is an error.
func resolveString(s, dir string) (string, error) {
	out, err := substituteTokens(s, dir, "env", func(arg, _ string) (string, error) {
		return expandEnv(arg)
	})
	if err != nil {
		return "", err
	}
	out, err = substituteTokens(out, dir, "file", expandFile)
	if err != nil {
		return "", err
	}
	if idx := strings.Index(out, "${"); idx >= 0 {
		token := out[idx:]
		if end := strings.Index(token, "}"); end >= 0 {
			token = token[:end+1]
		}
		return "", fmt.Errorf("config: unresolved interpolation %s", token)
	}
	return strings.ReplaceAll(out, "$$", "$"), nil
}

// interpolationToken locates a ${...} span in a source string.
type interpolationToken struct {
	start, end int // [start, end) covering the literal `${` ... `}`
	body       string
}

// findLeafTokens returns every "leaf" ${...} token — one whose body contains no
// nested ${. `$$` is honored as an escape and never starts a token. An
// unmatched ${ produces an error. Leaves are returned in document order.
func findLeafTokens(s string) ([]interpolationToken, error) {
	var stack []int
	var leaves []interpolationToken
	for i := 0; i < len(s); {
		c := s[i]
		if c == '$' && i+1 < len(s) {
			next := s[i+1]
			if next == '$' {
				i += 2
				continue
			}
			if next == '{' {
				stack = append(stack, i)
				i += 2
				continue
			}
		}
		if c == '}' && len(stack) > 0 {
			start := stack[len(stack)-1]
			stack = stack[:len(stack)-1]
			body := s[start+2 : i]
			if !strings.Contains(body, "${") {
				leaves = append(leaves, interpolationToken{start: start, end: i + 1, body: body})
			}
			i++
			continue
		}
		i++
	}
	if len(stack) > 0 {
		return nil, fmt.Errorf("config: unterminated interpolation in %q", s)
	}
	return leaves, nil
}

// substituteTokens replaces every leaf `${scheme:ARG}` in s with expand(ARG, dir).
// Tokens of other schemes pass through so a later phase can handle them. Nested
// tokens resolve innermost-first across phases.
func substituteTokens(s, dir, scheme string, expand func(arg, dir string) (string, error)) (string, error) {
	prefix := scheme + ":"
	leaves, err := findLeafTokens(s)
	if err != nil {
		return "", err
	}
	// Replace right-to-left so earlier positions stay valid as we mutate s.
	for i := len(leaves) - 1; i >= 0; i-- {
		l := leaves[i]
		if !strings.HasPrefix(l.body, prefix) {
			continue
		}
		replacement, err := expand(l.body[len(prefix):], dir)
		if err != nil {
			return "", err
		}
		s = s[:l.start] + replacement + s[l.end:]
	}
	return s, nil
}

// expandFile reads the file at path (relative to dir when not absolute) and
// returns its contents, trailing whitespace trimmed. A missing/unreadable file
// is an error — a referenced secret that isn't there must fail loudly.
func expandFile(path, dir string) (string, error) {
	full := path
	if !filepath.IsAbs(full) {
		full = filepath.Join(dir, path)
	}
	raw, err := os.ReadFile(full)
	if err != nil {
		return "", fmt.Errorf("config: file interpolation %q: %w", path, err)
	}
	return strings.TrimRight(string(raw), " \t\r\n"), nil
}

// expandEnv resolves ${env:VAR} or ${env:VAR:-default} through secret.Getenv
// (so VAR, VAR_FILE, and the systemd CREDENTIALS_DIRECTORY drop all work). An
// unset VAR with no default is an error.
func expandEnv(arg string) (string, error) {
	name := arg
	var defaultValue string
	hasDefault := false
	if idx := strings.Index(arg, ":-"); idx >= 0 {
		name = arg[:idx]
		defaultValue = arg[idx+2:]
		hasDefault = true
	}
	if name == "" {
		return "", fmt.Errorf("config: env interpolation: empty variable name in %q", arg)
	}
	if v := secret.Getenv(name); v != "" {
		return v, nil
	}
	if hasDefault {
		return defaultValue, nil
	}
	return "", fmt.Errorf("config: env interpolation: variable %s is not set", name)
}
