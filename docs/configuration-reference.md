<!-- AUTO-GENERATED — do not edit. Source: services/api/internal/config/keys.go.
Regenerate via `just gen-config-docs`. CI drift-checks this file. -->

# Configuration reference

Every tendant config key, its default, whether it is editable at runtime from the
admin surface, and when a change takes effect.

**Precedence (highest wins):** DB overlay (`config_entries`) > environment > config
file (`tendant.toml`) > code defaults.

**File search paths:** `./tendant.toml`, `$XDG_CONFIG_HOME/tendant/tendant.toml`,
`/etc/tendant/tendant.toml` (override with `--config`).

**Environment mapping:** nested keys map to `TENDANT_<SECTION>__<KEY>` (double
underscore = dot); the historical flat names (e.g. `DATABASE_URL`,
`TENDANT_OVERSEER_PROVIDER`) still work via aliases.

**DB-configurable** marks whether the key can be set at runtime via
`setConfigEntry`. Keys marked `—` must be set via file or environment.

**When change takes effect:**

- **hot** — applied immediately via `LISTEN/NOTIFY` (no restart).
- **restart** — persisted to the DB; applied on the next process restart.
- **bootstrap** — not changeable at runtime; set via file/env before start.

Keys marked 🔒 are sensitive: their values are redacted from logs and the admin
surface, and resolve through `internal/secret` (literal env, `${NAME}_FILE`, or
systemd `CREDENTIALS_DIRECTORY`).

## agent

| Key | Type | Default | DB-configurable | Takes effect | Description |
|---|---|---|---|---|---|
| `agent.connection` | string | `` | — | bootstrap | Name of an [[llm_connections]] entry the agent runner+router use (empty ⇒ human-only routing, no agent inference) |
| `agent.max_iter` | int | `20` | yes | restart | Per-stage max agent loop iterations |

## auth

| Key | Type | Default | DB-configurable | Takes effect | Description |
|---|---|---|---|---|---|
| `auth.password` 🔒 | string | — | — | bootstrap | Static device-pairing password (reusable; presented to pairDevice) |

## calibration

| Key | Type | Default | DB-configurable | Takes effect | Description |
|---|---|---|---|---|---|
| `calibration.demotion_decrement` | float64 | `0.25` | yes | hot | Trust-score decrement per bad signal |
| `calibration.intake_tighten_k` | float64 | `0.02` | yes | hot | Per-dismissal intake threshold-tightening coefficient |
| `calibration.maturation` | duration | `24h` | yes | hot | Per-row clean-outcome veto window |
| `calibration.min_sample` | int | `20` | yes | hot | Minimum matured samples before a routine is eligible |
| `calibration.ratio` | float64 | `0.9` | yes | hot | Matured-clean fraction required to propose promotion |
| `calibration.sweep_cron` | string | `0 * * * *` | yes | restart | Promotion-sweep cron cadence (applies on restart) |
| `calibration.window_n` | int | `50` | yes | hot | Rolling count window for the matured-clean ratio |

## credentials

| Key | Type | Default | DB-configurable | Takes effect | Description |
|---|---|---|---|---|---|
| `credentials.key` 🔒 | string | — | — | bootstrap | Base64 AES-256 key sealing source credentials |

## database

| Key | Type | Default | DB-configurable | Takes effect | Description |
|---|---|---|---|---|---|
| `database.url` 🔒 | string | — | — | bootstrap | PostgreSQL connection DSN |

## gate

| Key | Type | Default | DB-configurable | Takes effect | Description |
|---|---|---|---|---|---|
| `gate.call_budget` | int | `100` | yes | restart | Per-task max gated calls before fail-close to human |

## gatescript

| Key | Type | Default | DB-configurable | Takes effect | Description |
|---|---|---|---|---|---|
| `gatescript.asc_backend` | string | `` | — | bootstrap | Tier-1 server-compile backend: subprocess (non-sandboxed) or empty |
| `gatescript.asc_max_compile_ms` | int | `5000` | yes | restart | Max AssemblyScript compile time (ms) |
| `gatescript.asc_max_memory_pages` | int | `2048` | yes | restart | Max AssemblyScript compile memory pages |
| `gatescript.calendar_max_window_days` | int | `30` | yes | restart | Max calendar.query window (days) |
| `gatescript.compile_cache_mb` | int | `256` | yes | restart | Gate-script compile cache (MiB) |
| `gatescript.log_deny_pattern` | string | `` | yes | restart | LogRunner deny pattern (CI/testing) |
| `gatescript.max_memory_pages` | int | `256` | yes | restart | Max gate-script WASM memory pages |
| `gatescript.max_module_bytes` | int | `1048576` | yes | restart | Max gate-script module size (bytes) |
| `gatescript.max_timeout_ms` | int | `1000` | yes | restart | Max gate-script execution timeout (ms) |
| `gatescript.runner` | string | `wazero` | — | bootstrap | Gate-script runner: wazero, log |

## intake

| Key | Type | Default | DB-configurable | Takes effect | Description |
|---|---|---|---|---|---|
| `intake.gmail_client_id` | string | `` | — | bootstrap | Gmail OAuth client ID |
| `intake.gmail_client_secret` 🔒 | string | — | — | bootstrap | Gmail OAuth client secret |
| `intake.gmail_redirect_url` | string | `` | — | bootstrap | Gmail OAuth redirect URL |

## log

| Key | Type | Default | DB-configurable | Takes effect | Description |
|---|---|---|---|---|---|
| `log.format` | string | `json` | yes | restart | Log format: json |
| `log.level` | string | `info` | yes | hot | Log level: debug, info, warn, error |

## overseer

| Key | Type | Default | DB-configurable | Takes effect | Description |
|---|---|---|---|---|---|
| `overseer.anthropic.api_key` 🔒 | string | — | — | bootstrap | Anthropic API key |
| `overseer.anthropic.base_url` | string | `https://api.anthropic.com` | — | bootstrap | Anthropic base URL |
| `overseer.connection` | string | `` | — | bootstrap | Name of an [[llm_connections]] entry the overseer uses (empty ⇒ legacy overseer.provider) |
| `overseer.log_deny_pattern` | string | `` | yes | restart | LogProvider deny regexp (CI/testing) |
| `overseer.max_eval_per_task` | int | `50` | yes | hot | Per-task overseer evaluation cap (fail-closed beyond) |
| `overseer.model_id` | string | `log` | — | bootstrap | Overseer model identifier |
| `overseer.openai.api_key` 🔒 | string | — | — | bootstrap | OpenAI API key |
| `overseer.openai.base_url` | string | `https://api.openai.com` | — | bootstrap | OpenAI base URL |
| `overseer.provider` | string | `log` | — | bootstrap | Overseer provider: anthropic, openai, log |

## seed

| Key | Type | Default | DB-configurable | Takes effect | Description |
|---|---|---|---|---|---|
| `seed.example_gate_script` | bool | `false` | — | bootstrap | Seed the example gate script for send-email at boot |

## server

| Key | Type | Default | DB-configurable | Takes effect | Description |
|---|---|---|---|---|---|
| `server.http_addr` | string | `:8080` | — | bootstrap | HTTP listen address |

