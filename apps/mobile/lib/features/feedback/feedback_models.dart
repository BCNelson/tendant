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
  });

  final String id;
  final String taskTitle;
  final String? draftGuidance;
  final List<FeedbackMessageView> messages;
}

/// GuidanceScopeView mirrors the server GuidanceScope enum.
enum GuidanceScopeView { global, agent }

extension GuidanceScopeServer on GuidanceScopeView {
  String get serverName =>
      this == GuidanceScopeView.global ? 'GLOBAL' : 'AGENT';
}

/// The outcome of a feedback submit (accept/dismiss).
enum FeedbackSubmitResult { ok, serverError }
