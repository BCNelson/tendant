import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../inbox/inbox_page.dart' show inboxItemsProvider;
import '../routing/routing_provider.dart' show agentConfigsProvider;
import 'feedback_models.dart';
import 'feedback_provider.dart';

/// FeedbackDetailPage renders the post-completion feedback conversation: the
/// agent/owner chat, an editable draft-guidance field the owner can accept
/// verbatim (scoped global or to a specific agent), an optional satisfaction
/// rating, and Accept / Dismiss actions.
class FeedbackDetailPage extends ConsumerStatefulWidget {
  const FeedbackDetailPage({super.key, required this.decisionId});

  final String decisionId;

  @override
  ConsumerState<FeedbackDetailPage> createState() => _FeedbackDetailPageState();
}

class _FeedbackDetailPageState extends ConsumerState<FeedbackDetailPage> {
  final _messageCtrl = TextEditingController();
  final _draftCtrl = TextEditingController();

  bool _seeded = false;
  bool _busy = false;
  String _taskTitle = '';
  List<FeedbackMessageView> _messages = const [];
  GuidanceScopeView _scope = GuidanceScopeView.global;
  String? _agentConfigId;
  int? _rating;

  @override
  void dispose() {
    _messageCtrl.dispose();
    _draftCtrl.dispose();
    super.dispose();
  }

  void _seed(FeedbackConversationView c) {
    _seeded = true;
    _taskTitle = c.taskTitle;
    _messages = c.messages;
    _draftCtrl.text = c.draftGuidance ?? '';
  }

  Future<void> _send() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() => _busy = true);
    final updated = await ref
        .read(feedbackMutatorProvider)
        .send(widget.decisionId, text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _messageCtrl.clear();
      if (updated != null) {
        _messages = updated.messages;
        // Refresh the draft with the agent's latest proposal.
        _draftCtrl.text = updated.draftGuidance ?? _draftCtrl.text;
      }
    });
    if (updated == null) _toast('Could not send message.');
  }

  Future<void> _accept() async {
    if (_busy) return;
    if (_scope == GuidanceScopeView.agent && _agentConfigId == null) {
      _toast('Pick an agent for AGENT-scoped guidance.');
      return;
    }
    setState(() => _busy = true);
    final res = await ref.read(feedbackMutatorProvider).accept(
          widget.decisionId,
          _draftCtrl.text.trim(),
          _scope,
          _scope == GuidanceScopeView.agent ? _agentConfigId : null,
          _rating,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    _finish(res, 'Guidance accepted.');
  }

  Future<void> _dismiss() async {
    if (_busy) return;
    setState(() => _busy = true);
    final res =
        await ref.read(feedbackMutatorProvider).dismiss(widget.decisionId, _rating);
    if (!mounted) return;
    setState(() => _busy = false);
    _finish(res, 'Feedback closed.');
  }

  void _finish(FeedbackSubmitResult res, String okMessage) {
    if (res == FeedbackSubmitResult.ok) {
      ref.invalidate(inboxItemsProvider);
      _toast(okMessage);
      if (context.canPop()) context.pop();
    } else {
      _toast('Something went wrong. Try again.');
    }
  }

  void _toast(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(feedbackConversationProvider(widget.decisionId));
    // Seed local state once the conversation first loads.
    ref.listen(feedbackConversationProvider(widget.decisionId), (_, next) {
      next.whenData((c) {
        if (c != null && !_seeded) setState(() => _seed(c));
      });
    });
    async.whenData((c) {
      if (c != null && !_seeded) _seed(c);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_taskTitle.isEmpty ? 'Feedback' : 'Feedback · $_taskTitle'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (c) {
          if (c == null) {
            return const Center(child: Text('Feedback not found.'));
          }
          return Column(
            children: [
              Expanded(child: _chatList()),
              const Divider(height: 1),
              _composer(),
              const Divider(height: 1),
              _guidancePanel(),
            ],
          );
        },
      ),
    );
  }

  Widget _chatList() {
    if (_messages.isEmpty) {
      return const Center(child: Text('No messages yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final m = _messages[i];
        return Align(
          alignment: m.isAgent ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: m.isAgent
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(m.content),
          ),
        );
      },
    );
  }

  Widget _composer() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageCtrl,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Reply to the agent…',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            tooltip: 'Send',
            onPressed: _busy ? null : _send,
          ),
        ],
      ),
    );
  }

  Widget _guidancePanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Standing guidance',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          TextField(
            controller: _draftCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText:
                  'The agent drafts this from the conversation — edit it, then accept.',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          _scopeRow(),
          if (_scope == GuidanceScopeView.agent) _agentPicker(),
          const SizedBox(height: 8),
          _ratingRow(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : _dismiss,
                  child: const Text('Dismiss'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : _accept,
                  child: const Text('Accept guidance'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scopeRow() {
    return Row(
      children: [
        const Text('Applies to: '),
        const SizedBox(width: 8),
        SegmentedButton<GuidanceScopeView>(
          segments: const [
            ButtonSegment(value: GuidanceScopeView.global, label: Text('All agents')),
            ButtonSegment(value: GuidanceScopeView.agent, label: Text('One agent')),
          ],
          selected: {_scope},
          onSelectionChanged: (s) => setState(() => _scope = s.first),
        ),
      ],
    );
  }

  Widget _agentPicker() {
    final async = ref.watch(agentConfigsProvider(null));
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: async.when(
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text('Could not load agents: $e'),
        data: (configs) => DropdownButtonFormField<String>(
          initialValue: _agentConfigId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Agent',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            for (final c in configs)
              DropdownMenuItem(value: c.id, child: Text('${c.name} · ${c.stage.name}')),
          ],
          onChanged: (v) => setState(() => _agentConfigId = v),
        ),
      ),
    );
  }

  Widget _ratingRow() {
    return Row(
      children: [
        const Text('Rating: '),
        const SizedBox(width: 4),
        for (var n = 1; n <= 5; n++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ChoiceChip(
              label: Text('$n'),
              selected: _rating == n,
              onSelected: (sel) => setState(() => _rating = sel ? n : null),
            ),
          ),
      ],
    );
  }
}
