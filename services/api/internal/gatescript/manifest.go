package gatescript

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
)

// Manifest is the parsed, statically-enforced v1 capability manifest a gate
// script ships with. Its `reads` array is the allowlist that gates host-function
// imports (FR-010); `egress` must be the empty array (the only legal v1 value).
type Manifest struct {
	ManifestVersion string         `json:"manifest_version"` // "1" only
	Tool            string         `json:"tool"`             // must equal the target tool's global_uri
	Entrypoint      string         `json:"entrypoint"`       // "evaluate" only
	Reads           []string       `json:"reads"`
	Egress          []string       `json:"egress"` // [] only in v1
	Limits          ManifestLimits `json:"limits"`
}

// ManifestLimits declares the script's requested resource bounds. The host
// enforces min(declared, deployment ceiling); a manifest declaring limits above
// the ceiling is rejected at upload.
type ManifestLimits struct {
	TimeoutMs   int `json:"timeout_ms"`
	MemoryPages int `json:"memory_pages"`
}

// RejectReason enumerates the static-validation rejection reasons recorded in
// the gate_script_rejected audit row and mapped to GraphQL errors.
type RejectReason string

const (
	ReasonUndeclaredImport   RejectReason = "undeclared_import"
	ReasonEntrypointMismatch RejectReason = "entrypoint_mismatch"
	ReasonModuleTooLarge     RejectReason = "module_too_large"
	ReasonTimeoutExceeds     RejectReason = "timeout_exceeds_ceiling"
	ReasonMemoryExceeds      RejectReason = "memory_exceeds_ceiling"
	ReasonMalformedManifest  RejectReason = "malformed_manifest"
	ReasonToolMismatch       RejectReason = "tool_mismatch"
	ReasonUnknownCapability  RejectReason = "unknown_capability"
	ReasonVersionUnsupported RejectReason = "manifest_version_unsupported"
	ReasonCompileFailed      RejectReason = "compile_failed"
	ReasonEgressNotEmpty     RejectReason = "egress_not_empty"
)

// RejectError is a static-validation failure. It carries the structured reason
// plus optional reason-specific detail used in both the audit row and the
// INVALID_MANIFEST GraphQL error payload.
type RejectError struct {
	Reason  RejectReason
	Message string
	Detail  map[string]any
}

func (e *RejectError) Error() string {
	if e.Message != "" {
		return fmt.Sprintf("gate-script rejected (%s): %s", e.Reason, e.Message)
	}
	return fmt.Sprintf("gate-script rejected (%s)", e.Reason)
}

func reject(reason RejectReason, msg string, detail map[string]any) *RejectError {
	return &RejectError{Reason: reason, Message: msg, Detail: detail}
}

// v1Capabilities maps a manifest `reads` capability to the host-function NAME
// (under module "tendant") it authorizes. This is the canonical v1 set (FR-009).
var v1Capabilities = map[string]string{
	"call.args":    "call.get",
	"contacts":     "contacts.isKnown",
	"calendar":     "calendar.query",
	"task.context": "task.context",
	"owner.rule":   "owner.rule",
}

// hostFnToRead is the reverse map: a host-function name → the `reads`
// capability that must be declared to import it. The log sink is intentionally
// absent — it requires no declaration (FR-019).
var hostFnToRead = func() map[string]string {
	m := make(map[string]string, len(v1Capabilities))
	for read, fn := range v1Capabilities {
		m[fn] = read
	}
	return m
}()

// alwaysAllowedHostFns are host functions importable without a manifest `reads`
// entry. `log` is a bounded sink, not a read.
var alwaysAllowedHostFns = map[string]bool{"log": true}

// CanonicalManifestJSON returns the RFC-8785-shaped canonical JSON for a
// manifest: sorted keys, no insignificant whitespace. Marshaling the typed
// struct, round-tripping through interface{}, and re-marshaling yields
// deterministic sorted-key output (encoding/json sorts map keys). The manifest
// has no float fields, so no float-coercion concerns apply.
func CanonicalManifestJSON(m Manifest) ([]byte, error) {
	raw, err := json.Marshal(m)
	if err != nil {
		return nil, fmt.Errorf("marshal manifest: %w", err)
	}
	var generic any
	if err := json.Unmarshal(raw, &generic); err != nil {
		return nil, fmt.Errorf("normalize manifest: %w", err)
	}
	canonical, err := json.Marshal(generic)
	if err != nil {
		return nil, fmt.Errorf("canonicalize manifest: %w", err)
	}
	return canonical, nil
}

// ManifestHash is the sha256 hex of the canonical manifest JSON. It is the
// compile-cache key and the immutable identity recorded with every attach and
// every evaluation.
func ManifestHash(m Manifest) (string, error) {
	canonical, err := CanonicalManifestJSON(m)
	if err != nil {
		return "", err
	}
	sum := sha256.Sum256(canonical)
	return hex.EncodeToString(sum[:]), nil
}

// ParseManifest unmarshals a raw JSON manifest (as received from the GraphQL
// JSON scalar) into the typed struct. A structurally-malformed manifest is a
// ReasonMalformedManifest rejection.
func ParseManifest(raw json.RawMessage) (Manifest, error) {
	var m Manifest
	dec := json.NewDecoder(bytes.NewReader(raw))
	dec.DisallowUnknownFields()
	if err := dec.Decode(&m); err != nil {
		return Manifest{}, reject(ReasonMalformedManifest, err.Error(), nil)
	}
	return m, nil
}

// ValidateManifest enforces the grammar + ceiling rules (FR-008/FR-009/FR-012/
// FR-013) that do not require the WASM bytes. The import/export-section checks
// live in validate.go (they need the compiled module). toolGlobalURI is the
// target tool the owner is attaching to; manifest.tool must match it exactly.
func ValidateManifest(m Manifest, toolGlobalURI string, c Ceilings) error {
	if m.ManifestVersion != "1" {
		return reject(ReasonVersionUnsupported, fmt.Sprintf("manifest_version %q unsupported (want \"1\")", m.ManifestVersion), nil)
	}
	if m.Entrypoint != "evaluate" {
		return reject(ReasonMalformedManifest, fmt.Sprintf("entrypoint %q invalid (want \"evaluate\")", m.Entrypoint), nil)
	}
	if len(m.Egress) != 0 {
		return reject(ReasonEgressNotEmpty, "egress must be [] in v1 (external_fetch is reserved, not implementable)", nil)
	}
	if m.Tool == "" {
		return reject(ReasonMalformedManifest, "manifest.tool is required", nil)
	}
	if m.Tool != toolGlobalURI {
		return reject(ReasonToolMismatch, fmt.Sprintf("manifest.tool %q does not match target tool %q", m.Tool, toolGlobalURI),
			map[string]any{"manifest_tool": m.Tool, "target_tool": toolGlobalURI})
	}
	for _, r := range m.Reads {
		if _, ok := v1Capabilities[r]; !ok {
			return reject(ReasonUnknownCapability, fmt.Sprintf("unknown capability %q in reads", r),
				map[string]any{"capability": r})
		}
	}
	if m.Limits.TimeoutMs > c.MaxTimeoutMs {
		return reject(ReasonTimeoutExceeds, fmt.Sprintf("limits.timeout_ms %d exceeds ceiling %d", m.Limits.TimeoutMs, c.MaxTimeoutMs),
			map[string]any{"declared": m.Limits.TimeoutMs, "ceiling": c.MaxTimeoutMs})
	}
	if m.Limits.MemoryPages > c.MaxMemoryPages {
		return reject(ReasonMemoryExceeds, fmt.Sprintf("limits.memory_pages %d exceeds ceiling %d", m.Limits.MemoryPages, c.MaxMemoryPages),
			map[string]any{"declared": m.Limits.MemoryPages, "ceiling": c.MaxMemoryPages})
	}
	return nil
}

// EffectiveTimeoutMs / EffectiveMemoryPages enforce min(manifest, ceiling) at
// runtime (FR-013). A zero or negative manifest value falls back to the ceiling
// default so a malformed-but-accepted manifest still runs bounded.
func (m Manifest) EffectiveTimeoutMs(c Ceilings) int {
	return minPositive(m.Limits.TimeoutMs, c.MaxTimeoutMs)
}

func (m Manifest) EffectiveMemoryPages(c Ceilings) int {
	return minPositive(m.Limits.MemoryPages, c.MaxMemoryPages)
}

func minPositive(declared, ceiling int) int {
	if declared <= 0 || declared > ceiling {
		return ceiling
	}
	return declared
}
