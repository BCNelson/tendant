package gatescript

import (
	"testing"

	"github.com/stretchr/testify/require"
)

// config_test.go pins the exact env-var names + defaults the deployment relies
// on. A renamed/typo'd var would silently fall back to a default on first
// deploy (e.g. an operator tightening TENDANT_GATESCRIPT_MAX_TIMEOUT_MS would be
// ignored) — these tests fail loudly instead.

var allCeilingEnv = []string{
	"TENDANT_GATESCRIPT_MAX_MODULE_BYTES",
	"TENDANT_GATESCRIPT_MAX_TIMEOUT_MS",
	"TENDANT_GATESCRIPT_MAX_MEMORY_PAGES",
	"TENDANT_GATESCRIPT_CALENDAR_MAX_WINDOW_DAYS",
	"TENDANT_GATESCRIPT_COMPILE_CACHE_MB",
	"TENDANT_ASC_MAX_COMPILE_MS",
	"TENDANT_ASC_MAX_MEMORY_PAGES",
}

func TestCeilingsFromEnv_DefaultsWhenUnset(t *testing.T) {
	for _, k := range allCeilingEnv {
		t.Setenv(k, "") // empty = unset for envInt
	}
	require.Equal(t, DefaultCeilings(), CeilingsFromEnv())
}

func TestCeilingsFromEnv_EachVarIsRead(t *testing.T) {
	// Set each var to a distinct value and assert it lands in the right field —
	// this catches a mis-mapped env var name.
	t.Setenv("TENDANT_GATESCRIPT_MAX_MODULE_BYTES", "11")
	t.Setenv("TENDANT_GATESCRIPT_MAX_TIMEOUT_MS", "22")
	t.Setenv("TENDANT_GATESCRIPT_MAX_MEMORY_PAGES", "33")
	t.Setenv("TENDANT_GATESCRIPT_CALENDAR_MAX_WINDOW_DAYS", "44")
	t.Setenv("TENDANT_GATESCRIPT_COMPILE_CACHE_MB", "55")
	t.Setenv("TENDANT_ASC_MAX_COMPILE_MS", "66")
	t.Setenv("TENDANT_ASC_MAX_MEMORY_PAGES", "77")

	c := CeilingsFromEnv()
	require.Equal(t, 11, c.MaxModuleBytes)
	require.Equal(t, 22, c.MaxTimeoutMs)
	require.Equal(t, 33, c.MaxMemoryPages)
	require.Equal(t, 44, c.CalendarMaxWindowDays)
	require.Equal(t, 55, c.CompileCacheMB)
	require.Equal(t, 66, c.ASCMaxCompileMs)
	require.Equal(t, 77, c.ASCMaxMemoryPages)
}

func TestCeilingsFromEnv_InvalidValueFallsBackToDefault(t *testing.T) {
	t.Setenv("TENDANT_GATESCRIPT_MAX_TIMEOUT_MS", "not-a-number")
	t.Setenv("TENDANT_GATESCRIPT_MAX_MEMORY_PAGES", "-5") // non-positive ignored
	c := CeilingsFromEnv()
	require.Equal(t, DefaultCeilings().MaxTimeoutMs, c.MaxTimeoutMs)
	require.Equal(t, DefaultCeilings().MaxMemoryPages, c.MaxMemoryPages)
}

func TestRunnerKind(t *testing.T) {
	t.Setenv("TENDANT_GATESCRIPT_RUNNER", "log")
	require.Equal(t, "log", RunnerKind())
	t.Setenv("TENDANT_GATESCRIPT_RUNNER", "wazero")
	require.Equal(t, "wazero", RunnerKind())
	// Anything unrecognized (or unset) defaults to the production runner.
	t.Setenv("TENDANT_GATESCRIPT_RUNNER", "garbage")
	require.Equal(t, "wazero", RunnerKind())
	t.Setenv("TENDANT_GATESCRIPT_RUNNER", "")
	require.Equal(t, "wazero", RunnerKind())
}

func TestDefaultCeilings_MatchQuickstartDocumentedValues(t *testing.T) {
	c := DefaultCeilings()
	require.Equal(t, 1<<20, c.MaxModuleBytes) // 1 MiB
	require.Equal(t, 1000, c.MaxTimeoutMs)
	require.Equal(t, 256, c.MaxMemoryPages)
	require.Equal(t, 30, c.CalendarMaxWindowDays)
	require.Equal(t, 256, c.CompileCacheMB)
	require.Equal(t, 5000, c.ASCMaxCompileMs)
	require.Equal(t, 2048, c.ASCMaxMemoryPages)
}
