package config

import (
	"os"
	"path/filepath"
	"testing"
	"time"
)

func TestLoad_Defaults(t *testing.T) {
	t.Setenv("XDG_CONFIG_HOME", t.TempDir())
	cfg, err := Load("")
	if err != nil {
		t.Fatalf("Load: %v", err)
	}
	if cfg.Server.HTTPAddr != ":8080" {
		t.Errorf("HTTPAddr = %q, want :8080", cfg.Server.HTTPAddr)
	}
	if cfg.Calibration.Ratio != 0.90 {
		t.Errorf("Ratio = %v, want 0.90", cfg.Calibration.Ratio)
	}
	if cfg.Calibration.Maturation != 24*time.Hour {
		t.Errorf("Maturation = %v, want 24h", cfg.Calibration.Maturation)
	}
	if cfg.Overseer.Provider != "log" {
		t.Errorf("Provider = %q, want log", cfg.Overseer.Provider)
	}
}

func TestLoad_FileOverridesDefault(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "tendant.toml")
	content := `
[server]
http_addr = ":9999"

[calibration]
ratio = 0.5
maturation = "1h"

[[agents]]
name = "file-agent"
stage = "triage"
system_prompt = "from file"
eligibility = "{}"
`
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
	cfg, err := Load(path)
	if err != nil {
		t.Fatalf("Load: %v", err)
	}
	if cfg.Server.HTTPAddr != ":9999" {
		t.Errorf("HTTPAddr = %q, want :9999 (file)", cfg.Server.HTTPAddr)
	}
	if cfg.Calibration.Ratio != 0.5 {
		t.Errorf("Ratio = %v, want 0.5 (file)", cfg.Calibration.Ratio)
	}
	if cfg.Calibration.Maturation != time.Hour {
		t.Errorf("Maturation = %v, want 1h (file)", cfg.Calibration.Maturation)
	}
	if len(cfg.Agents) != 1 || cfg.Agents[0].Name != "file-agent" {
		t.Errorf("Agents = %+v, want one file-agent", cfg.Agents)
	}
}

func TestLoad_EnvOverridesFile(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "tendant.toml")
	if err := os.WriteFile(path, []byte("[server]\nhttp_addr = \":9999\"\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	// New-style nested env.
	t.Setenv("TENDANT_SERVER__HTTP_ADDR", ":7777")
	cfg, err := Load(path)
	if err != nil {
		t.Fatalf("Load: %v", err)
	}
	if cfg.Server.HTTPAddr != ":7777" {
		t.Errorf("HTTPAddr = %q, want :7777 (env beats file)", cfg.Server.HTTPAddr)
	}
}

func TestLoad_LegacyEnvAliases(t *testing.T) {
	t.Setenv("DATABASE_URL", "postgres://legacy/db")
	t.Setenv("TENDANT_OVERSEER_PROVIDER", "anthropic")
	t.Setenv("TENDANT_CALIBRATION_RATIO", "0.42")
	t.Setenv("TENDANT_GATE_CALL_BUDGET", "7")
	t.Setenv("XDG_CONFIG_HOME", t.TempDir())
	cfg, err := Load("")
	if err != nil {
		t.Fatalf("Load: %v", err)
	}
	if cfg.Database.URL != "postgres://legacy/db" {
		t.Errorf("Database.URL = %q (legacy alias)", cfg.Database.URL)
	}
	if cfg.Overseer.Provider != "anthropic" {
		t.Errorf("Overseer.Provider = %q (legacy alias)", cfg.Overseer.Provider)
	}
	if cfg.Calibration.Ratio != 0.42 {
		t.Errorf("Calibration.Ratio = %v (legacy alias coercion)", cfg.Calibration.Ratio)
	}
	if cfg.Gate.CallBudget != 7 {
		t.Errorf("Gate.CallBudget = %v (legacy alias coercion)", cfg.Gate.CallBudget)
	}
}

func TestLoad_SecretFileIndirection(t *testing.T) {
	dir := t.TempDir()
	secretFile := filepath.Join(dir, "key")
	if err := os.WriteFile(secretFile, []byte("s3cr3t\n"), 0o600); err != nil {
		t.Fatal(err)
	}
	t.Setenv("TENDANT_CREDENTIALS_KEY_FILE", secretFile)
	t.Setenv("XDG_CONFIG_HOME", t.TempDir())
	cfg, err := Load("")
	if err != nil {
		t.Fatalf("Load: %v", err)
	}
	if cfg.Credentials.Key != "s3cr3t" {
		t.Errorf("Credentials.Key = %q, want s3cr3t (trimmed file)", cfg.Credentials.Key)
	}
}

func TestEncodeDecodeValue(t *testing.T) {
	reg := RegistryMap()
	cases := []struct {
		key, in, want string
	}{
		{"calibration.ratio", "0.95", "0.95"},
		{"gate.call_budget", "42", "42"},
		{"calibration.maturation", "30m", "30m0s"},
		{"log.level", "debug", "debug"},
		{"seed.example_gate_script", "true", "true"},
	}
	for _, c := range cases {
		def, ok := reg[c.key]
		if !ok {
			t.Fatalf("registry missing %s", c.key)
		}
		enc, err := EncodeValue(def, c.in)
		if err != nil {
			t.Fatalf("EncodeValue(%s,%s): %v", c.key, c.in, err)
		}
		if got := DecodeStored(def, enc); got != c.want {
			t.Errorf("round-trip %s: got %q want %q", c.key, got, c.want)
		}
	}
}

func TestEncodeValue_TypeErrors(t *testing.T) {
	reg := RegistryMap()
	if _, err := EncodeValue(reg["gate.call_budget"], "notanint"); err == nil {
		t.Error("expected error for non-int budget")
	}
	if _, err := EncodeValue(reg["calibration.ratio"], "nope"); err == nil {
		t.Error("expected error for non-float ratio")
	}
	if _, err := EncodeValue(reg["calibration.maturation"], "5"); err == nil {
		t.Error("expected error for bare-number duration")
	}
}

func TestOverlayNilSafe(t *testing.T) {
	var o *Overlay
	if got := o.IntOr("x", 9); got != 9 {
		t.Errorf("nil overlay IntOr = %d, want 9", got)
	}
	if got := o.StringOr("x", "d"); got != "d" {
		t.Errorf("nil overlay StringOr = %q, want d", got)
	}
	if _, ok := o.Lookup("x"); ok {
		t.Error("nil overlay Lookup should be (_, false)")
	}
}

func TestFlat(t *testing.T) {
	cfg := DefaultConfig()
	flat := cfg.Flat()
	if flat["server.http_addr"] != ":8080" {
		t.Errorf("flat[server.http_addr] = %v", flat["server.http_addr"])
	}
	if _, ok := flat["agents"]; ok {
		t.Error("flat should omit catalog slices")
	}
}
