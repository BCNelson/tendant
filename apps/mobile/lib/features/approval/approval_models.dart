/// Phase 3 in-memory shapes that mirror the GraphQL `ApprovalRequest` +
/// `Artifact` types. Kept separate from generated Ferry types so the
/// approval UI is testable without a live GraphQL link — the bootstrap
/// layer (T077) will hydrate these from the generated query results.
library;

/// Discriminated kinds of an Artifact payload. New tools that introduce
/// new kinds extend this enum (and the matching server-side
/// `artifactKindForTool` in `graph/phase3_helpers.go`).
enum ArtifactKind { email, generic }

ArtifactKind artifactKindFromString(String s) {
  switch (s) {
    case 'email':
      return ArtifactKind.email;
    default:
      return ArtifactKind.generic;
  }
}

/// Artifact carries the frozen tool-call payload the operator is being
/// asked to approve. `recipient` is the canonical "who is affected" hint
/// so the UI can lead with it; `content` is the full per-tool body.
class Artifact {
  const Artifact({
    required this.kind,
    required this.content,
    this.recipient,
  });

  final ArtifactKind kind;
  final Map<String, dynamic> content;
  final String? recipient;

  String get subject => (content['subject'] ?? '') as String;
  String get body => (content['body'] ?? '') as String;
}

/// OverseerEvaluationView is the read-only view-model for the Phase 4
/// `OverseerEvaluation` GraphQL type. Lives here so both
/// `ApprovalRequestView` and the card widget can reference it without an
/// import cycle.
class OverseerEvaluationView {
  const OverseerEvaluationView({
    required this.verdict,
    required this.summary,
    required this.consideredFields,
    required this.modelId,
    required this.provider,
    required this.tokensIn,
    required this.tokensOut,
    required this.estimatedCostUsd,
  });

  final String verdict;
  final String summary;
  final List<String> consideredFields;
  final String modelId;
  final String provider;
  final int tokensIn;
  final int tokensOut;
  final double estimatedCostUsd;
}

/// ApprovalRequestView is what the ApprovalDetailPage renders. The
/// `toolName` is the human-readable name (display label) of the tool
/// behind the request — pulled from the `Tool.name` field.
class ApprovalRequestView {
  const ApprovalRequestView({
    required this.id,
    required this.toolName,
    required this.toolGlobalUri,
    required this.artifact,
    this.overseerEvaluation,
  });

  final String id;
  final String toolName;
  final String toolGlobalUri;
  final Artifact artifact;

  /// Phase 4: non-null when the overseer was the layer that escalated
  /// this approval; null for floor-raised approvals.
  final OverseerEvaluationView? overseerEvaluation;
}
