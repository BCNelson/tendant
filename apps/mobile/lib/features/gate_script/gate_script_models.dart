/// View model for a gate script's verdict + evidence as rendered on the
/// ApprovalDetailPage (Phase 5). Presentation-layer type, separate from the
/// generated Ferry types; the bootstrap layer hydrates it from the
/// `ApprovalRequest.gateScriptEvaluation` query result.
class GateScriptVerdictView {
  const GateScriptVerdictView({
    required this.verdict,
    required this.summary,
    required this.consideredFields,
    required this.hostcallTrace,
    required this.scriptVersion,
  });

  final String verdict;
  final String summary;
  final List<String> consideredFields;
  final List<String> hostcallTrace;
  final int scriptVersion;
}
