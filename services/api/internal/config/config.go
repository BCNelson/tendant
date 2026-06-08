// Package config is tendant's single configuration entry point. It resolves a
// boot snapshot with koanf (defaults < file < env) and exposes a DB-backed
// Overlay (config_entries) that wins at runtime for DB-configurable keys.
//
// Effective precedence (highest wins): DB overlay > env > file > code defaults.
//
//   - Boot snapshot (Load) — used for bootstrap/restart keys read once at start.
//   - Overlay (overlay.go) — typed *Or(key, fallback) reads for hot keys, where
//     fallback is the boot-snapshot value, yielding DB > env > file > defaults.
//
// Sensitive values still flow through internal/secret (literal env, ${NAME}_FILE,
// or systemd CREDENTIALS_DIRECTORY) via the legacy-env alias layer, so secrets
// never need to land in the TOML file.
package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/knadh/koanf/parsers/toml"
	"github.com/knadh/koanf/providers/confmap"
	"github.com/knadh/koanf/providers/env"
	"github.com/knadh/koanf/providers/file"
	"github.com/knadh/koanf/providers/structs"
	"github.com/knadh/koanf/v2"

	"github.com/bcnelson/tendant/services/api/internal/secret"
)

// Config is the full resolved boot snapshot. Scalar sections are file+env+DB
// configurable; the catalog slices (Agents/Tools/Connectors) are file+DB only
// (env is awkward for nested lists) and reconciled into the DB on boot.
type Config struct {
	Server      ServerConfig      `koanf:"server"`
	Database    DatabaseConfig    `koanf:"database"`
	Log         LogConfig         `koanf:"log"`
	Gate        GateConfig        `koanf:"gate"`
	Agent       AgentRunnerConfig `koanf:"agent"`
	Overseer    OverseerConfig    `koanf:"overseer"`
	Gatescript  GatescriptConfig  `koanf:"gatescript"`
	Calibration CalibrationConfig `koanf:"calibration"`
	Intake      IntakeConfig      `koanf:"intake"`
	Setup       SetupConfig       `koanf:"setup"`
	Credentials CredentialsConfig `koanf:"credentials"`
	Seed        SeedConfig        `koanf:"seed"`

	// Catalogs — file + DB, not env. Empty ⇒ the boot reconcilers fall back to
	// the in-code default catalog (existing seeders).
	Agents     []AgentDef     `koanf:"agents"`
	Tools      []ToolDef      `koanf:"tools"`
	Connectors []ConnectorDef `koanf:"connectors"`

	// LLMConnections — file-defined named model endpoints (the internal/llm
	// registry). Many connections of the same provider are allowed (e.g. two
	// OpenAI-compatible backends). Boot-fixed: inference routing is not
	// runtime-addressable. Secrets resolve via ${env:...}/${file:...}
	// interpolation in the connection's credential fields.
	LLMConnections []ConnectionDef `koanf:"llm_connections"`
}

// ServerConfig holds HTTP server settings.
type ServerConfig struct {
	HTTPAddr string `koanf:"http_addr"`
}

// DatabaseConfig holds database connection settings.
type DatabaseConfig struct {
	URL string `koanf:"url"`
}

// LogConfig holds logging settings.
type LogConfig struct {
	Level  string `koanf:"level"`
	Format string `koanf:"format"`
}

// GateConfig holds the per-task gate budget.
type GateConfig struct {
	CallBudget int `koanf:"call_budget"`
}

// AgentRunnerConfig holds agent-layer budget controls.
type AgentRunnerConfig struct {
	MaxIter int `koanf:"max_iter"`
}

// OverseerConfig holds the Phase-4 overseer (LLM grader) settings.
type OverseerConfig struct {
	// Connection, when set, names an [[llm_connections]] entry the overseer
	// uses — the multi-connection path. When empty, the legacy
	// Provider/ModelID/Anthropic/OpenAI fields select the provider.
	Connection     string             `koanf:"connection"`
	Provider       string             `koanf:"provider"`
	ModelID        string             `koanf:"model_id"`
	MaxEvalPerTask int                `koanf:"max_eval_per_task"`
	LogDenyPattern string             `koanf:"log_deny_pattern"`
	Anthropic      ProviderHTTPConfig `koanf:"anthropic"`
	OpenAI         ProviderHTTPConfig `koanf:"openai"`
}

// ProviderHTTPConfig is the shared shape for an HTTP LLM provider.
type ProviderHTTPConfig struct {
	APIKey  string `koanf:"api_key"`
	BaseURL string `koanf:"base_url"`
}

// GatescriptConfig holds the Phase-5 gate-script runner + ceilings.
type GatescriptConfig struct {
	Runner                string `koanf:"runner"`
	MaxModuleBytes        int    `koanf:"max_module_bytes"`
	MaxTimeoutMs          int    `koanf:"max_timeout_ms"`
	MaxMemoryPages        int    `koanf:"max_memory_pages"`
	CalendarMaxWindowDays int    `koanf:"calendar_max_window_days"`
	CompileCacheMB        int    `koanf:"compile_cache_mb"`
	ASCMaxCompileMs       int    `koanf:"asc_max_compile_ms"`
	ASCMaxMemoryPages     int    `koanf:"asc_max_memory_pages"`
	ASCBackend            string `koanf:"asc_backend"`
	LogDenyPattern        string `koanf:"log_deny_pattern"`
}

// CalibrationConfig holds the Phase-8 calibration knobs.
type CalibrationConfig struct {
	Maturation        time.Duration `koanf:"maturation"`
	WindowN           int           `koanf:"window_n"`
	Ratio             float64       `koanf:"ratio"`
	MinSample         int           `koanf:"min_sample"`
	DemotionDecrement float64       `koanf:"demotion_decrement"`
	SweepCron         string        `koanf:"sweep_cron"`
	IntakeTightenK    float64       `koanf:"intake_tighten_k"`
}

// IntakeConfig holds the Phase-7 intake-edge connector credentials.
type IntakeConfig struct {
	GmailClientID     string `koanf:"gmail_client_id"`
	GmailClientSecret string `koanf:"gmail_client_secret"`
	GmailRedirectURL  string `koanf:"gmail_redirect_url"`
}

// SetupConfig holds the device-pairing one-time secret.
type SetupConfig struct {
	Secret string `koanf:"secret"`
}

// CredentialsConfig holds the AES key for sealing source credentials.
type CredentialsConfig struct {
	Key string `koanf:"key"`
}

// SeedConfig holds boot-time example-seeding toggles.
type SeedConfig struct {
	ExampleGateScript bool `koanf:"example_gate_script"`
}

// AgentDef is a file/DB-definable agent specialist (reconciled into agent_configs).
type AgentDef struct {
	Name          string   `koanf:"name"`
	Stage         string   `koanf:"stage"`
	SystemPrompt  string   `koanf:"system_prompt"`
	Model         string   `koanf:"model"`
	ToolAllowlist []string `koanf:"tool_allowlist"`
	Eligibility   string   `koanf:"eligibility"` // JSON expression (internal/router grammar)
}

// ToolDef is a file/DB-definable tool (reconciled into tools).
type ToolDef struct {
	GlobalURI            string         `koanf:"global_uri"`
	Name                 string         `koanf:"name"`
	Rung                 string         `koanf:"rung"`
	OverseerInstructions string         `koanf:"overseer_instructions"`
	Permissions          map[string]any `koanf:"permissions"`
}

// ConnectionDef is a file-definable named model endpoint (the internal/llm
// registry). Credential fields accept ${env:NAME} / ${file:PATH} interpolation
// (see interpolate.go), so secrets need never be inlined — e.g.
// api_key = "${env:OPENAI_API_KEY}" or api_key = "${file:/run/secrets/openai}".
type ConnectionDef struct {
	Name     string `koanf:"name"`
	Provider string `koanf:"provider"` // openai | anthropic | gemini | bedrock | log
	BaseURL  string `koanf:"base_url"`
	Model    string `koanf:"model"`

	APIKey string `koanf:"api_key"`

	// Bedrock (AWS SigV4).
	Region          string `koanf:"region"`
	AccessKeyID     string `koanf:"access_key_id"`
	SecretAccessKey string `koanf:"secret_access_key"`
	SessionToken    string `koanf:"session_token"`
}

// ConnectorDef is a file/DB-definable connector (reconciled into connector_configs).
type ConnectorDef struct {
	ID               string         `koanf:"id"`
	Type             string         `koanf:"type"`
	Schedule         string         `koanf:"schedule"`
	Filter           map[string]any `koanf:"filter"`
	DispositionRules map[string]any `koanf:"disposition_rules"`
	Enabled          bool           `koanf:"enabled"`
}

// Load resolves the boot snapshot with precedence env > file > defaults. If
// configPath is empty the standard search paths are checked. Sensitive keys are
// additionally resolved through internal/secret via the legacy-env alias layer.
func Load(configPath string) (*Config, error) {
	k := koanf.New(".")

	// 1. Defaults (lowest priority).
	if err := k.Load(structs.Provider(DefaultConfig(), "koanf"), nil); err != nil {
		return nil, fmt.Errorf("config: load defaults: %w", err)
	}

	// 2. Config file (TOML). File-sourced values get ${env:...}/${file:...}
	//    interpolation (see interpolate.go); env/defaults pass through raw so a
	//    value that legitimately contains "${" is never mangled.
	path := configPath
	if path == "" {
		path = findConfigFile()
	}
	if path != "" {
		fileK := koanf.New(".")
		if err := fileK.Load(file.Provider(path), toml.Parser()); err != nil {
			return nil, fmt.Errorf("config: load file %s: %w", path, err)
		}
		resolved, err := interpolate(fileK.Raw(), filepath.Dir(path))
		if err != nil {
			return nil, fmt.Errorf("config: interpolate %s: %w", path, err)
		}
		rmap, _ := resolved.(map[string]any)
		if err := k.Load(confmap.Provider(rmap, "."), nil); err != nil {
			return nil, fmt.Errorf("config: load file %s: %w", path, err)
		}
	}

	// 3. New-style nested env (TENDANT_SERVER__HTTP_ADDR → server.http_addr).
	if err := k.Load(env.Provider("TENDANT_", ".", func(s string) string {
		return strings.ReplaceAll(strings.ToLower(strings.TrimPrefix(s, "TENDANT_")), "__", ".")
	}), nil); err != nil {
		return nil, fmt.Errorf("config: load env: %w", err)
	}

	// 4. Legacy flat env names + secret indirection (highest of the env tier),
	//    so existing deployments and ${NAME}_FILE / systemd creds keep working.
	if am := legacyAliasMap(); len(am) > 0 {
		if err := k.Load(confmap.Provider(am, "."), nil); err != nil {
			return nil, fmt.Errorf("config: load legacy aliases: %w", err)
		}
	}

	var cfg Config
	if err := k.Unmarshal("", &cfg); err != nil {
		return nil, fmt.Errorf("config: unmarshal: %w", err)
	}
	return &cfg, nil
}

// aliasEntry maps a legacy flat env var to its canonical koanf key.
type aliasEntry struct {
	Env       string
	Key       string
	Sensitive bool // resolve via secret.Getenv (literal | _FILE | systemd)
}

// legacyAliases is the back-compat table: every historical env var tendant read
// before the unified config, mapped to its canonical key. Keep in sync with keys.go.
var legacyAliases = []aliasEntry{
	{Env: "DATABASE_URL", Key: "database.url", Sensitive: true},
	{Env: "HTTP_ADDR", Key: "server.http_addr"},
	{Env: "TENDANT_GATE_CALL_BUDGET", Key: "gate.call_budget"},
	{Env: "TENDANT_AGENT_MAX_ITER", Key: "agent.max_iter"},
	{Env: "TENDANT_OVERSEER_CONNECTION", Key: "overseer.connection"},
	{Env: "TENDANT_OVERSEER_PROVIDER", Key: "overseer.provider"},
	{Env: "TENDANT_OVERSEER_MODEL_ID", Key: "overseer.model_id"},
	{Env: "TENDANT_OVERSEER_MAX_EVAL_PER_TASK", Key: "overseer.max_eval_per_task"},
	{Env: "TENDANT_OVERSEER_ANTHROPIC_API_KEY", Key: "overseer.anthropic.api_key", Sensitive: true},
	{Env: "TENDANT_OVERSEER_ANTHROPIC_BASE_URL", Key: "overseer.anthropic.base_url"},
	{Env: "TENDANT_OVERSEER_OPENAI_API_KEY", Key: "overseer.openai.api_key", Sensitive: true},
	{Env: "TENDANT_OVERSEER_OPENAI_BASE_URL", Key: "overseer.openai.base_url"},
	{Env: "TENDANT_OVERSEER_LOG_DENY_PATTERN", Key: "overseer.log_deny_pattern"},
	{Env: "TENDANT_GATESCRIPT_RUNNER", Key: "gatescript.runner"},
	{Env: "TENDANT_GATESCRIPT_MAX_MODULE_BYTES", Key: "gatescript.max_module_bytes"},
	{Env: "TENDANT_GATESCRIPT_MAX_TIMEOUT_MS", Key: "gatescript.max_timeout_ms"},
	{Env: "TENDANT_GATESCRIPT_MAX_MEMORY_PAGES", Key: "gatescript.max_memory_pages"},
	{Env: "TENDANT_GATESCRIPT_CALENDAR_MAX_WINDOW_DAYS", Key: "gatescript.calendar_max_window_days"},
	{Env: "TENDANT_GATESCRIPT_COMPILE_CACHE_MB", Key: "gatescript.compile_cache_mb"},
	{Env: "TENDANT_ASC_MAX_COMPILE_MS", Key: "gatescript.asc_max_compile_ms"},
	{Env: "TENDANT_ASC_MAX_MEMORY_PAGES", Key: "gatescript.asc_max_memory_pages"},
	{Env: "TENDANT_ASC_BACKEND", Key: "gatescript.asc_backend"},
	{Env: "TENDANT_GATESCRIPT_LOG_DENY_PATTERN", Key: "gatescript.log_deny_pattern"},
	{Env: "TENDANT_CALIBRATION_MATURATION", Key: "calibration.maturation"},
	{Env: "TENDANT_CALIBRATION_WINDOW_N", Key: "calibration.window_n"},
	{Env: "TENDANT_CALIBRATION_RATIO", Key: "calibration.ratio"},
	{Env: "TENDANT_CALIBRATION_MIN_SAMPLE", Key: "calibration.min_sample"},
	{Env: "TENDANT_CALIBRATION_DEMOTION_DECREMENT", Key: "calibration.demotion_decrement"},
	{Env: "TENDANT_CALIBRATION_SWEEP_CRON", Key: "calibration.sweep_cron"},
	{Env: "TENDANT_CALIBRATION_INTAKE_TIGHTEN_K", Key: "calibration.intake_tighten_k"},
	{Env: "TENDANT_GMAIL_CLIENT_ID", Key: "intake.gmail_client_id"},
	{Env: "TENDANT_GMAIL_CLIENT_SECRET", Key: "intake.gmail_client_secret", Sensitive: true},
	{Env: "TENDANT_GMAIL_REDIRECT_URL", Key: "intake.gmail_redirect_url"},
	{Env: "TENDANT_CREDENTIALS_KEY", Key: "credentials.key", Sensitive: true},
	{Env: "TENDANT_SETUP_SECRET", Key: "setup.secret", Sensitive: true},
	{Env: "TENDANT_SEED_EXAMPLE_GATE_SCRIPT", Key: "seed.example_gate_script"},
}

// legacyAliasMap builds the confmap of present legacy env vars. Sensitive vars
// flow through secret.Getenv so ${NAME}_FILE / systemd LoadCredential still work.
func legacyAliasMap() map[string]any {
	out := map[string]any{}
	for _, a := range legacyAliases {
		var v string
		if a.Sensitive {
			v = secret.Getenv(a.Env)
		} else {
			v = os.Getenv(a.Env)
		}
		if v != "" {
			out[a.Key] = v
		}
	}
	return out
}

// findConfigFile returns the first existing config path, or "".
func findConfigFile() string {
	for _, p := range configSearchPaths() {
		if _, err := os.Stat(p); err == nil {
			return p
		}
	}
	return ""
}

// configSearchPaths returns the XDG-compliant search paths.
func configSearchPaths() []string {
	paths := []string{"tendant.toml"}
	xdg := os.Getenv("XDG_CONFIG_HOME")
	if xdg == "" {
		if home, err := os.UserHomeDir(); err == nil {
			xdg = filepath.Join(home, ".config")
		}
	}
	if xdg != "" {
		paths = append(paths, filepath.Join(xdg, "tendant", "tendant.toml"))
	}
	return append(paths, "/etc/tendant/tendant.toml")
}
