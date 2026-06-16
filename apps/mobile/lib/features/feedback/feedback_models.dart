// View models for the post-completion feedback conversation.

enum FeedbackRole { agent, user }

FeedbackRole feedbackRoleFromString(String s) =>
    s == 'user' ? FeedbackRole.user : FeedbackRole.agent;

class FeedbackMessageView {
  const FeedbackMessageView({
    required this.id,
    required this.role,
    required this.content,
  });

  final String id;
  final FeedbackRole role;
  final String content;

  bool get isAgent => role == FeedbackRole.agent;
}

class FeedbackConversationView {
  const FeedbackConversationView({
    required this.id,
    required this.taskTitle,
    required this.draftGuidance,
    required this.messages,
    this.context,
  });

  final String id;
  final String taskTitle;
  final String? draftGuidance;
  final List<FeedbackMessageView> messages;

  /// Read-only digest of what happened on the completed task — the same context
  /// the feedback agent saw. Null when the server could not build it.
  final FeedbackContextView? context;
}

/// FeedbackContextView mirrors the server FeedbackContext: a read-only summary of
/// the completed task plus the context tools the agent consulted.
class FeedbackContextView {
  const FeedbackContextView({
    required this.toolsRun,
    required this.toolsFlagged,
    required this.agentStages,
    required this.activeGuidanceCount,
    required this.consulted,
    required this.summary,
    this.handoffReason,
  });

  final int toolsRun;
  final int toolsFlagged;
  final List<String> agentStages;
  final int activeGuidanceCount;
  final List<String> consulted;
  final String summary;
  final String? handoffReason;

  bool get isEmpty =>
      toolsRun == 0 &&
      agentStages.isEmpty &&
      consulted.isEmpty &&
      activeGuidanceCount == 0 &&
      (handoffReason == null || handoffReason!.isEmpty);
}

/// GuidanceScopeView mirrors the server GuidanceScope enum.
enum GuidanceScopeView { global, agent }

extension GuidanceScopeServer on GuidanceScopeView {
  String get serverName =>
      this == GuidanceScopeView.global ? 'GLOBAL' : 'AGENT';
}

/// The outcome of a feedback submit (accept/dismiss).
enum FeedbackSubmitResult { ok, serverError }
