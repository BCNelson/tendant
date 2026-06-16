package config

import "time"

// DefaultConfig returns the code-level defaults — the lowest-precedence layer.
// These mirror the values tendant previously hard-coded across server.LoadConfig,
// the build*Config funcs, and the subsystem *FromEnv constructors.
//
// Catalog slices (Agents/Tools/Connectors) are intentionally empty: when a
// config file does not define them, the boot reconcilers fall back to the
// in-code default catalog (the existing seeders), preserving prior behavior.
func DefaultConfig() Config {
	return Config{
		Server: ServerConfig{
			HTTPAddr: ":8080",
		},
		Database: DatabaseConfig{
			URL: "",
		},
		Log: LogConfig{
			Level:  "info",
			Format: "json",
		},
		Gate: GateConfig{
			CallBudget: 100,
		},
		Agent: AgentRunnerConfig{
			MaxIter: 20,
		},
		Overseer: OverseerConfig{
			Provider:       "log",
			ModelID:        "log",
			MaxEvalPerTask: 50, // overseer.DefaultMaxEvalPerTask
			Anthropic:      ProviderHTTPConfig{BaseURL: "https://api.anthropic.com"},
			OpenAI:         ProviderHTTPConfig{BaseURL: "https://api.openai.com"},
		},
		Gatescript: GatescriptConfig{
			Runner:                "wazero",
			MaxModuleBytes:        1 << 20, // 1 MiB
			MaxTimeoutMs:          1000,
			MaxMemoryPages:        256,
			CalendarMaxWindowDays: 30,
			CompileCacheMB:        256,
			ASCMaxCompileMs:       5000,
			ASCMaxMemoryPages:     2048,
			ASCBackend:            "",
		},
		Calibration: CalibrationConfig{
			Maturation:        24 * time.Hour,
			WindowN:           50,
			Ratio:             0.90,
			MinSample:         20,
			DemotionDecrement: 0.25,
			SweepCron:         "0 * * * *",
			IntakeTightenK:    0.02,
		},
		Inbox: InboxConfig{
			ReconcileCron: "*/15 * * * *",
		},
		Embedding: EmbeddingConfig{
			// Disabled by default (triage uses the full-taxonomy fallback). The
			// other fields pre-fill the Ollama dev setup so enabling embeddings
			// is just `provider = "openai"` (see tendant.example.toml).
			Provider:   "",
			Model:      "nomic-embed-text",
			BaseURL:    "http://localhost:11434/v1",
			Dimension:  768,
			TriageTopK: 10,
		},
		Seed: SeedConfig{
			ExampleGateScript: false,
		},
	}
}
