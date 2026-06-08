package config

import (
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/knadh/koanf/providers/structs"
	"github.com/knadh/koanf/v2"
)

// Flat returns every scalar config value keyed by its dotted registry key
// (e.g. "calibration.ratio"). Used to report the boot-resolved effective value
// before the DB overlay is applied. Catalog slices are omitted.
func (c *Config) Flat() map[string]any {
	k := koanf.New(".")
	_ = k.Load(structs.Provider(*c, "koanf"), nil)
	all := k.All()
	out := make(map[string]any, len(all))
	for key, v := range all {
		if strings.HasPrefix(key, "agents") || strings.HasPrefix(key, "tools") || strings.HasPrefix(key, "connectors") {
			continue
		}
		out[key] = v
	}
	return out
}

// StringifyValue renders a config value as a human-facing string for the admin
// surface. Durations stored as int64 nanoseconds are rendered as Go durations.
func StringifyValue(def KeyDef, v any) string {
	if v == nil {
		return ""
	}
	switch def.Type {
	case "duration":
		switch d := v.(type) {
		case time.Duration:
			return d.String()
		case int64:
			return time.Duration(d).String()
		case int:
			return time.Duration(d).String()
		case float64:
			return time.Duration(int64(d)).String()
		case string:
			return d
		}
	case "bool":
		return fmt.Sprintf("%v", v)
	}
	return fmt.Sprintf("%v", v)
}

// EncodeValue validates a raw scalar string against the key's declared type and
// returns the canonical jsonb encoding to store in config_entries.
func EncodeValue(def KeyDef, raw string) (json.RawMessage, error) {
	raw = strings.TrimSpace(raw)
	switch def.Type {
	case "string":
		return json.Marshal(raw)
	case "int":
		n, err := strconv.Atoi(raw)
		if err != nil {
			return nil, fmt.Errorf("value for %q must be an integer: %w", def.Key, err)
		}
		return json.Marshal(n)
	case "float64":
		f, err := strconv.ParseFloat(raw, 64)
		if err != nil {
			return nil, fmt.Errorf("value for %q must be a number: %w", def.Key, err)
		}
		return json.Marshal(f)
	case "bool":
		b, err := strconv.ParseBool(raw)
		if err != nil {
			return nil, fmt.Errorf("value for %q must be a boolean: %w", def.Key, err)
		}
		return json.Marshal(b)
	case "duration":
		d, err := time.ParseDuration(raw)
		if err != nil {
			return nil, fmt.Errorf("value for %q must be a Go duration (e.g. 30m): %w", def.Key, err)
		}
		return json.Marshal(d.String())
	default:
		return nil, fmt.Errorf("unknown key type %q", def.Type)
	}
}

// DecodeStored renders a stored jsonb override value back to its display string.
func DecodeStored(def KeyDef, raw json.RawMessage) string {
	switch def.Type {
	case "string", "duration":
		var s string
		if err := json.Unmarshal(raw, &s); err == nil {
			return s
		}
	case "int":
		var n int
		if err := json.Unmarshal(raw, &n); err == nil {
			return strconv.Itoa(n)
		}
	case "float64":
		var f float64
		if err := json.Unmarshal(raw, &f); err == nil {
			return strconv.FormatFloat(f, 'f', -1, 64)
		}
	case "bool":
		var b bool
		if err := json.Unmarshal(raw, &b); err == nil {
			return strconv.FormatBool(b)
		}
	}
	return strings.TrimSpace(string(raw))
}
