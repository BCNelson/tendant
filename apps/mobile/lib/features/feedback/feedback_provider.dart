import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feedback_models.dart';

/// FeedbackMutator is the seam the feedback UI calls to drive the conversation
/// and resolve it. The real Ferry implementation is wired in the bootstrap
/// layer; tests override this provider with an in-memory recorder.
abstract class FeedbackMutator {
  /// Append the owner's message; returns the refreshed conversation (with the
  /// agent's reply + draft), or null on error.
  Future<FeedbackConversationView?> send(String decisionId, String text);

  /// Accept `guidance` verbatim at `scope` (agentConfigId required when AGENT),
  /// optionally with a 1–5 rating.
  Future<FeedbackSubmitResult> accept(
    String decisionId,
    String guidance,
    GuidanceScopeView scope,
    String? agentConfigId,
    int? rating,
  );

  /// Close the conversation with no guidance (optional rating).
  Future<FeedbackSubmitResult> dismiss(String decisionId, int? rating);
}

/// feedbackConversationProvider is the per-decision conversation loader,
/// overridden by the bootstrap layer with a Ferry query.
///
/// autoDispose: the conversation is fully persisted server-side (the message
/// thread + the agent's draft guidance), so the page must re-fetch each time it
/// is opened. Without autoDispose the family caches the first snapshot — the
/// opening message with an empty draft — and leaving + returning would replay
/// that stale state, losing the chat history and draft built up in between.
final feedbackConversationProvider =
    FutureProvider.autoDispose.family<FeedbackConversationView?, String>(
        (ref, _) async => null);

/// feedbackMutatorProvider is overridden by the bootstrap layer with a Ferry
/// client. The default is a no-op so widgets compile and tests can override.
final feedbackMutatorProvider = Provider<FeedbackMutator>((ref) {
  return _NoopFeedbackMutator();
});

class _NoopFeedbackMutator implements FeedbackMutator {
  @override
  Future<FeedbackConversationView?> send(String decisionId, String text) async =>
      null;
  @override
  Future<FeedbackSubmitResult> accept(String decisionId, String guidance,
          GuidanceScopeView scope, String? agentConfigId, int? rating) async =>
      FeedbackSubmitResult.serverError;
  @override
  Future<FeedbackSubmitResult> dismiss(String decisionId, int? rating) async =>
      FeedbackSubmitResult.serverError;
}
