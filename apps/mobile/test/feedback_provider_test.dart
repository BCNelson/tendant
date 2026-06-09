import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tendant/features/feedback/feedback_models.dart';
import 'package:tendant/features/feedback/feedback_provider.dart';

FeedbackConversationView _convo(String id, List<String> userMsgs) {
  return FeedbackConversationView(
    id: id,
    taskTitle: 'Write a poem',
    draftGuidance: userMsgs.isEmpty ? null : 'Always write it yourself.',
    messages: [
      const FeedbackMessageView(
        id: 'open',
        role: FeedbackRole.agent,
        content: 'How did it go?',
      ),
      for (var i = 0; i < userMsgs.length; i++)
        FeedbackMessageView(
          id: 'u$i',
          role: FeedbackRole.user,
          content: userMsgs[i],
        ),
    ],
  );
}

void main() {
  test(
      'feedbackConversationProvider re-fetches the persisted thread on re-entry '
      '(autoDispose) instead of replaying the stale opening snapshot', () async {
    // The "backend": what a fresh fetch returns. It grows as the owner chats,
    // mirroring the server persisting each turn.
    var serverState = _convo('d1', const []);
    var fetchCount = 0;

    final container = ProviderContainer(
      overrides: [
        feedbackConversationProvider.overrideWith((ref, id) async {
          fetchCount++;
          return serverState;
        }),
      ],
    );
    addTearDown(container.dispose);

    // First open: the page watches the provider.
    final sub1 =
        container.listen(feedbackConversationProvider('d1'), (_, __) {});
    final first = await container.read(feedbackConversationProvider('d1').future);
    expect(fetchCount, 1);
    expect(first!.messages.length, 1); // just the opening message

    // The owner chats; the server now holds the full thread + a real draft.
    serverState = _convo('d1', const ['the agent should write it itself']);

    // Leaving the page removes the only listener → autoDispose tears it down.
    sub1.close();
    await Future<void>.delayed(Duration.zero);

    // Returning to the page re-watches: a non-autoDispose family would replay
    // the cached opening snapshot, but autoDispose forces a fresh fetch.
    container.listen(feedbackConversationProvider('d1'), (_, __) {});
    final second =
        await container.read(feedbackConversationProvider('d1').future);

    expect(fetchCount, 2, reason: 'provider should re-fetch after disposal');
    expect(second!.messages.length, 2); // opening + the owner's reply
    expect(second.draftGuidance, 'Always write it yourself.');
  });
}
