/// Plain view models for the read-only gate-script surface (Phase 5). Kept
/// independent of ferry-generated types so the widgets compile + widget-test
/// standalone; the providers map GraphQL responses into these.

/// GateScriptVerdictView backs the GateScriptVerdictCard on ApprovalDetailPage —
/// shown when a gate script (not the floor or overseer) escalated the approval.
class GateScriptVerdictView {
  const GateScriptVerdictView({
    required this.verdict,
    required this.summary,
    required this.consideredFields,
    required this.hostcallTrace,
    required this.scriptVersion,
    required this.manifestHash,
  });

  final String verdict;
  final String summary;
  final List<String> consideredFields;
  final List<String> hostcallTrace;
  final int scriptVersion;
  final String manifestHash;
}

/// GateScriptDetailView backs the read-only GateScriptDetailPage.
class GateScriptDetailView {
  const GateScriptDetailView({
    required this.version,
    required this.tier,
    required this.status,
    required this.attachedByPrincipal,
    required this.attachedAt,
    required this.manifestHash,
    this.source,
  });

  final int version;
  final String tier; // ASSEMBLYSCRIPT_IN_APP | BYO_WASM
  final String status; // ACTIVE | DISABLED
  final String attachedByPrincipal;
  final DateTime attachedAt;
  final String manifestHash;
  final String? source; // populated for Tier 1; null for Tier 2. NEVER the wasm.
}
