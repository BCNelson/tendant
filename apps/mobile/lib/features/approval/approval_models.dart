/// Phase 3 in-memory shapes that mirror the GraphQL `ApprovalRequest` +
/// `Artifact` types. Kept separate from generated Ferry types so the
/// approval UI is testable without a live GraphQL link — the bootstrap
/// layer (T077) will hydrate these from the generated query results.

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

/// ApprovalRequestView is what the ApprovalDetailPage renders. The
/// `toolName` is the human-readable name (display label) of the tool
/// behind the request — pulled from the `Tool.name` field.
class ApprovalRequestView {
  const ApprovalRequestView({
    required this.id,
    required this.toolName,
    required this.toolGlobalUri,
    required this.artifact,
  });

  final String id;
  final String toolName;
  final String toolGlobalUri;
  final Artifact artifact;
}
