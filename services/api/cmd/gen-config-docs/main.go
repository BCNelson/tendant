// Command gen-config-docs walks config.Registry and emits a Markdown reference
// of every tendant config key. The generated file is committed so CI can
// drift-check it (regenerate + git diff). Invoked via `just gen-config-docs`.
package main

import (
	"fmt"
	"os"
	"sort"
	"strings"

	"github.com/bcnelson/tendant/services/api/internal/config"
)

const header = `<!-- AUTO-GENERATED — do not edit. Source: services/api/internal/config/keys.go.
Regenerate via ` + "`just gen-config-docs`" + `. CI drift-checks this file. -->

# Configuration reference

Every tendant config key, its default, whether it is editable at runtime from the
admin surface, and when a change takes effect.

**Precedence (highest wins):** DB overlay (` + "`config_entries`" + `) > environment > config
file (` + "`tendant.toml`" + `) > code defaults.

**File search paths:** ` + "`./tendant.toml`" + `, ` + "`$XDG_CONFIG_HOME/tendant/tendant.toml`" + `,
` + "`/etc/tendant/tendant.toml`" + ` (override with ` + "`--config`" + `).

**Environment mapping:** nested keys map to ` + "`TENDANT_<SECTION>__<KEY>`" + ` (double
underscore = dot); the historical flat names (e.g. ` + "`DATABASE_URL`" + `,
` + "`TENDANT_OVERSEER_PROVIDER`" + `) still work via aliases.

**DB-configurable** marks whether the key can be set at runtime via
` + "`setConfigEntry`" + `. Keys marked ` + "`—`" + ` must be set via file or environment.

**When change takes effect:**

- **hot** — applied immediately via ` + "`LISTEN/NOTIFY`" + ` (no restart).
- **restart** — persisted to the DB; applied on the next process restart.
- **bootstrap** — not changeable at runtime; set via file/env before start.

Keys marked 🔒 are sensitive: their values are redacted from logs and the admin
surface, and resolve through ` + "`internal/secret`" + ` (literal env, ` + "`${NAME}_FILE`" + `, or
systemd ` + "`CREDENTIALS_DIRECTORY`" + `).

`

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintln(os.Stderr, "usage: gen-config-docs <output-path>")
		os.Exit(2)
	}
	outPath := os.Args[1]

	sections := map[string][]config.KeyDef{}
	for _, k := range config.Registry {
		head, _, _ := strings.Cut(k.Key, ".")
		sections[head] = append(sections[head], k)
	}
	names := make([]string, 0, len(sections))
	for name := range sections {
		names = append(names, name)
	}
	sort.Strings(names)

	var b strings.Builder
	b.WriteString(header)
	for _, name := range names {
		keys := sections[name]
		sort.Slice(keys, func(i, j int) bool { return keys[i].Key < keys[j].Key })
		fmt.Fprintf(&b, "## %s\n\n", name)
		b.WriteString("| Key | Type | Default | DB-configurable | Takes effect | Description |\n")
		b.WriteString("|---|---|---|---|---|---|\n")
		for _, k := range keys {
			key := "`" + k.Key + "`"
			if k.Sensitive {
				key += " 🔒"
			}
			def := "`" + config.StringifyValue(k, k.Default) + "`"
			if k.Sensitive {
				def = "—"
			}
			dbc := "—"
			if k.DBConfigurable {
				dbc = "yes"
			}
			effect := string(k.Reload)
			if k.DBConfigurable && !k.HotReloadable && k.Reload == config.ReloadHot {
				effect = "restart"
			}
			fmt.Fprintf(&b, "| %s | %s | %s | %s | %s | %s |\n",
				key, k.Type, def, dbc, effect, k.Description)
		}
		b.WriteString("\n")
	}

	if err := os.WriteFile(outPath, []byte(b.String()), 0o644); err != nil {
		fmt.Fprintf(os.Stderr, "write %s: %v\n", outPath, err)
		os.Exit(1)
	}
}
