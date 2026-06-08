package config

// ReloadCategory indicates when a config change takes effect.
type ReloadCategory string

const (
	ReloadHot       ReloadCategory = "hot"       // takes effect immediately (read through Overlay)
	ReloadRestart   ReloadCategory = "restart"   // persisted; applies on next process restart
	ReloadBootstrap ReloadCategory = "bootstrap" // not changeable at runtime
)

// KeyDef describes one config key's metadata. It drives admin-boundary
// validation, secret redaction, the generated docs, and which keys the UI may
// edit.
//
// Reload is the intended timing of a change; HotReloadable is the actual runtime
// behavior — true only for keys whose consuming code reads through config.Overlay
// on every use. A key may be Reload=hot but HotReloadable=false when the registry
// entry has landed before the consumer was migrated; the admin API then reports
// restart-required so operators aren't misled.
type KeyDef struct {
	Key            string         `json:"key"`
	Type           string         `json:"type"` // string | int | bool | duration | float64
	Default        any            `json:"default_value"`
	Description    string         `json:"description"`
	Reload         ReloadCategory `json:"reload"`
	Sensitive      bool           `json:"sensitive"`
	DBConfigurable bool           `json:"db_configurable"`
	HotReloadable  bool           `json:"hot_reloadable"`
	ReadonlyReason string         `json:"readonly_reason,omitempty"`
}

// Registry holds every known scalar config key. Catalog definitions
// (agents/tools/connectors) are file+DB and not listed here.
var Registry = []KeyDef{
	// Server / database — bootstrap.
	{Key: "server.http_addr", Type: "string", Default: ":8080", Description: "HTTP listen address", Reload: ReloadBootstrap, DBConfigurable: false, ReadonlyReason: "Server bind address cannot change at runtime"},
	{Key: "database.url", Type: "string", Default: "", Description: "PostgreSQL connection DSN", Reload: ReloadBootstrap, Sensitive: true, DBConfigurable: false, ReadonlyReason: "Database connection cannot change at runtime"},

	// Logging.
	{Key: "log.level", Type: "string", Default: "info", Description: "Log level: debug, info, warn, error", Reload: ReloadHot, DBConfigurable: true, HotReloadable: true},
	{Key: "log.format", Type: "string", Default: "json", Description: "Log format: json", Reload: ReloadRestart, DBConfigurable: true},

	// Gate / agent budgets — hot.
	{Key: "gate.call_budget", Type: "int", Default: 100, Description: "Per-task max gated calls before fail-close to human", Reload: ReloadHot, DBConfigurable: true, HotReloadable: false},
	{Key: "agent.max_iter", Type: "int", Default: 20, Description: "Per-stage max agent loop iterations", Reload: ReloadHot, DBConfigurable: true, HotReloadable: false},

	// Overseer — provider selection is boot-only (agents cannot reroute inference).
	{Key: "overseer.provider", Type: "string", Default: "log", Description: "Overseer provider: anthropic, openai, log", Reload: ReloadBootstrap, DBConfigurable: false, ReadonlyReason: "Inference routing is fixed at boot (no self-escalation)"},
	{Key: "overseer.model_id", Type: "string", Default: "log", Description: "Overseer model identifier", Reload: ReloadBootstrap, DBConfigurable: false, ReadonlyReason: "Inference routing is fixed at boot"},
	{Key: "overseer.max_eval_per_task", Type: "int", Default: 50, Description: "Per-task overseer evaluation cap (fail-closed beyond)", Reload: ReloadHot, DBConfigurable: true, HotReloadable: true},
	{Key: "overseer.log_deny_pattern", Type: "string", Default: "", Description: "LogProvider deny regexp (CI/testing)", Reload: ReloadRestart, DBConfigurable: true},
	{Key: "overseer.anthropic.api_key", Type: "string", Default: "", Description: "Anthropic API key", Reload: ReloadBootstrap, Sensitive: true, DBConfigurable: false, ReadonlyReason: "Provider credentials are read at boot"},
	{Key: "overseer.anthropic.base_url", Type: "string", Default: "https://api.anthropic.com", Description: "Anthropic base URL", Reload: ReloadBootstrap, DBConfigurable: false},
	{Key: "overseer.openai.api_key", Type: "string", Default: "", Description: "OpenAI API key", Reload: ReloadBootstrap, Sensitive: true, DBConfigurable: false, ReadonlyReason: "Provider credentials are read at boot"},
	{Key: "overseer.openai.base_url", Type: "string", Default: "https://api.openai.com", Description: "OpenAI base URL", Reload: ReloadBootstrap, DBConfigurable: false},

	// Gate scripts — ops-owned ceilings, read at boot (FR-013).
	{Key: "gatescript.runner", Type: "string", Default: "wazero", Description: "Gate-script runner: wazero, log", Reload: ReloadBootstrap, DBConfigurable: false, ReadonlyReason: "Runner is selected at boot"},
	{Key: "gatescript.max_module_bytes", Type: "int", Default: 1 << 20, Description: "Max gate-script module size (bytes)", Reload: ReloadRestart, DBConfigurable: true},
	{Key: "gatescript.max_timeout_ms", Type: "int", Default: 1000, Description: "Max gate-script execution timeout (ms)", Reload: ReloadRestart, DBConfigurable: true},
	{Key: "gatescript.max_memory_pages", Type: "int", Default: 256, Description: "Max gate-script WASM memory pages", Reload: ReloadRestart, DBConfigurable: true},
	{Key: "gatescript.calendar_max_window_days", Type: "int", Default: 30, Description: "Max calendar.query window (days)", Reload: ReloadRestart, DBConfigurable: true},
	{Key: "gatescript.compile_cache_mb", Type: "int", Default: 256, Description: "Gate-script compile cache (MiB)", Reload: ReloadRestart, DBConfigurable: true},
	{Key: "gatescript.asc_max_compile_ms", Type: "int", Default: 5000, Description: "Max AssemblyScript compile time (ms)", Reload: ReloadRestart, DBConfigurable: true},
	{Key: "gatescript.asc_max_memory_pages", Type: "int", Default: 2048, Description: "Max AssemblyScript compile memory pages", Reload: ReloadRestart, DBConfigurable: true},
	{Key: "gatescript.asc_backend", Type: "string", Default: "", Description: "Tier-1 server-compile backend: subprocess (non-sandboxed) or empty", Reload: ReloadBootstrap, DBConfigurable: false, ReadonlyReason: "Compiler backend is selected at boot"},
	{Key: "gatescript.log_deny_pattern", Type: "string", Default: "", Description: "LogRunner deny pattern (CI/testing)", Reload: ReloadRestart, DBConfigurable: true},

	// Calibration ratchet.
	{Key: "calibration.maturation", Type: "duration", Default: "24h", Description: "Per-row clean-outcome veto window", Reload: ReloadHot, DBConfigurable: true, HotReloadable: true},
	{Key: "calibration.window_n", Type: "int", Default: 50, Description: "Rolling count window for the matured-clean ratio", Reload: ReloadHot, DBConfigurable: true, HotReloadable: true},
	{Key: "calibration.ratio", Type: "float64", Default: 0.90, Description: "Matured-clean fraction required to propose promotion", Reload: ReloadHot, DBConfigurable: true, HotReloadable: true},
	{Key: "calibration.min_sample", Type: "int", Default: 20, Description: "Minimum matured samples before a routine is eligible", Reload: ReloadHot, DBConfigurable: true, HotReloadable: true},
	{Key: "calibration.demotion_decrement", Type: "float64", Default: 0.25, Description: "Trust-score decrement per bad signal", Reload: ReloadHot, DBConfigurable: true, HotReloadable: true},
	{Key: "calibration.sweep_cron", Type: "string", Default: "0 * * * *", Description: "Promotion-sweep cron cadence (applies on restart)", Reload: ReloadRestart, DBConfigurable: true},
	{Key: "calibration.intake_tighten_k", Type: "float64", Default: 0.02, Description: "Per-dismissal intake threshold-tightening coefficient", Reload: ReloadHot, DBConfigurable: true, HotReloadable: true},

	// Intake (Gmail OAuth) — credentials read at boot.
	{Key: "intake.gmail_client_id", Type: "string", Default: "", Description: "Gmail OAuth client ID", Reload: ReloadBootstrap, DBConfigurable: false},
	{Key: "intake.gmail_client_secret", Type: "string", Default: "", Description: "Gmail OAuth client secret", Reload: ReloadBootstrap, Sensitive: true, DBConfigurable: false, ReadonlyReason: "OAuth credentials are read at boot"},
	{Key: "intake.gmail_redirect_url", Type: "string", Default: "", Description: "Gmail OAuth redirect URL", Reload: ReloadBootstrap, DBConfigurable: false},

	// Secrets / boot toggles.
	{Key: "credentials.key", Type: "string", Default: "", Description: "Base64 AES-256 key sealing source credentials", Reload: ReloadBootstrap, Sensitive: true, DBConfigurable: false, ReadonlyReason: "Sealing key is read at boot"},
	{Key: "setup.secret", Type: "string", Default: "", Description: "One-time device-pairing setup secret (armed per boot)", Reload: ReloadBootstrap, Sensitive: true, DBConfigurable: false, ReadonlyReason: "Setup secret is armed at boot"},
	{Key: "seed.example_gate_script", Type: "bool", Default: false, Description: "Seed the example gate script for send-email at boot", Reload: ReloadBootstrap, DBConfigurable: false, ReadonlyReason: "Seeding runs at boot"},
}

// RegistryMap returns the registry keyed by config key.
func RegistryMap() map[string]KeyDef {
	m := make(map[string]KeyDef, len(Registry))
	for _, k := range Registry {
		m[k.Key] = k
	}
	return m
}
