package gatescript

import (
	"os"
	"strconv"
)

// Ceilings are the per-deployment resource bounds a manifest cannot relax
// (FR-013). They are operations-team-owned (env vars), not GraphQL-addressable.
// The host enforces min(manifest-declared, ceiling) at runtime, and rejects a
// manifest declaring limits above the ceiling at upload.
type Ceilings struct {
	MaxModuleBytes        int // TENDANT_GATESCRIPT_MAX_MODULE_BYTES
	MaxTimeoutMs          int // TENDANT_GATESCRIPT_MAX_TIMEOUT_MS
	MaxMemoryPages        int // TENDANT_GATESCRIPT_MAX_MEMORY_PAGES
	CalendarMaxWindowDays int // TENDANT_GATESCRIPT_CALENDAR_MAX_WINDOW_DAYS
	CompileCacheMB        int // TENDANT_GATESCRIPT_COMPILE_CACHE_MB
	ASCMaxCompileMs       int // TENDANT_ASC_MAX_COMPILE_MS
	ASCMaxMemoryPages     int // TENDANT_ASC_MAX_MEMORY_PAGES
}

// DefaultCeilings returns the documented Phase-5 defaults (quickstart.md).
func DefaultCeilings() Ceilings {
	return Ceilings{
		MaxModuleBytes:        1 << 20, // 1 MiB
		MaxTimeoutMs:          1000,
		MaxMemoryPages:        256,
		CalendarMaxWindowDays: 30,
		CompileCacheMB:        256,
		ASCMaxCompileMs:       5000,
		ASCMaxMemoryPages:     2048,
	}
}

// CeilingsFromEnv reads the TENDANT_GATESCRIPT_* / TENDANT_ASC_* env vars,
// falling back to DefaultCeilings for any unset or non-positive value.
func CeilingsFromEnv() Ceilings {
	c := DefaultCeilings()
	c.MaxModuleBytes = envInt("TENDANT_GATESCRIPT_MAX_MODULE_BYTES", c.MaxModuleBytes)
	c.MaxTimeoutMs = envInt("TENDANT_GATESCRIPT_MAX_TIMEOUT_MS", c.MaxTimeoutMs)
	c.MaxMemoryPages = envInt("TENDANT_GATESCRIPT_MAX_MEMORY_PAGES", c.MaxMemoryPages)
	c.CalendarMaxWindowDays = envInt("TENDANT_GATESCRIPT_CALENDAR_MAX_WINDOW_DAYS", c.CalendarMaxWindowDays)
	c.CompileCacheMB = envInt("TENDANT_GATESCRIPT_COMPILE_CACHE_MB", c.CompileCacheMB)
	c.ASCMaxCompileMs = envInt("TENDANT_ASC_MAX_COMPILE_MS", c.ASCMaxCompileMs)
	c.ASCMaxMemoryPages = envInt("TENDANT_ASC_MAX_MEMORY_PAGES", c.ASCMaxMemoryPages)
	return c
}

// RunnerKind selects the production WazeroRunner or the deterministic LogRunner
// from TENDANT_GATESCRIPT_RUNNER (default "wazero"; CI/tests override to "log").
func RunnerKind() string {
	switch os.Getenv("TENDANT_GATESCRIPT_RUNNER") {
	case "log":
		return "log"
	default:
		return "wazero"
	}
}

func envInt(key string, def int) int {
	if raw := os.Getenv(key); raw != "" {
		if n, err := strconv.Atoi(raw); err == nil && n > 0 {
			return n
		}
	}
	return def
}
