import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../task/task_provider.dart' show taskChangedProvider;
import 'activity_format.dart';
import 'tasks_models.dart';
import 'tasks_provider.dart';

/// TaskDetailPage shows everything that happened on a task: header + state,
/// per-stage occupancy, the agent output (findings), and the full audit
/// timeline (agent runs, tool calls, gate verdicts, outcomes, transitions).
/// Refreshes live off the per-task `taskChanged` subscription.
class TaskDetailPage extends ConsumerWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Live-refresh while the task is still running.
    ref.listen(taskChangedProvider(taskId), (_, __) {
      ref.invalidate(taskDetailProvider(taskId));
    });

    final detail = ref.watch(taskDetailProvider(taskId));
    final task = detail.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit priority & due date',
            onPressed: task == null
                ? null
                : () => _showEditMetadata(context, ref, task),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(taskDetailProvider(taskId)),
          ),
        ],
      ),
      body: detail.when(
        data: (t) => t == null
            ? const Center(child: Text('Task not found.'))
            : _DetailBody(task: t),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.task});

  final TaskDetail task;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(task.title, style: Theme.of(context).textTheme.titleLarge),
        if (task.description != null && task.description!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(task.description!),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _Chip(label: task.state),
            _Chip(label: 'stage: ${task.currentStage}'),
            _Chip(label: 'autonomy: ${task.autonomy}'),
            _Chip(label: 'priority: ${task.priority}'),
            if (task.dueAt != null)
              _Chip(label: 'due: ${_formatDate(task.dueAt!)}'),
          ],
        ),
        const SizedBox(height: 16),
        _SectionTitle('Specialists'),
        ...task.stageSlots.map((s) => ListTile(
              dense: true,
              leading: Icon(s.isHuman ? Icons.person : Icons.smart_toy),
              title: Text(s.stage.name.toUpperCase()),
              subtitle: Text(s.isHuman
                  ? 'You'
                  : (s.occupantName ?? 'not yet routed')),
              trailing: s.occupantModel != null ? Text(s.occupantModel!) : null,
            )),
        if (task.findings.isNotEmpty) ...[
          const SizedBox(height: 8),
          _SectionTitle('Agent output'),
          _Findings(findings: task.findings),
        ],
        const SizedBox(height: 8),
        _SectionTitle('Activity'),
        if (task.activity.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('No activity recorded.'),
          )
        else
          ...task.activity.map((e) => _ActivityTile(event: e)),
      ],
    );
  }
}

// Date-only display for a task's due date, e.g. "2026-06-09".
String _formatDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

// Owner-set priorities, ascending. Mirrors the create screen.
const _priorities = ['LOW', 'NORMAL', 'HIGH', 'URGENT'];

/// Opens the priority + due-date editor, pre-filled with the task's current
/// metadata. On save it calls updateTaskMetadata and refreshes the detail.
Future<void> _showEditMetadata(
    BuildContext context, WidgetRef ref, TaskDetail task) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _EditMetadataSheet(task: task),
    ),
  );
}

/// _EditMetadataSheet is the bottom-sheet form for editing a task's priority
/// and (optional) due date after creation.
class _EditMetadataSheet extends ConsumerStatefulWidget {
  const _EditMetadataSheet({required this.task});

  final TaskDetail task;

  @override
  ConsumerState<_EditMetadataSheet> createState() => _EditMetadataSheetState();
}

class _EditMetadataSheetState extends ConsumerState<_EditMetadataSheet> {
  late String _priority = _priorities.contains(widget.task.priority)
      ? widget.task.priority
      : 'NORMAL';
  late DateTime? _dueAt = widget.task.dueAt;
  String? _error;
  bool _saving = false;

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _dueAt = picked);
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final update = await ref.read(updateTaskMetadataProvider.future);
      await update(widget.task.id, priority: _priority, dueAt: _dueAt);
      ref.invalidate(taskDetailProvider(widget.task.id));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Edit task metadata',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: [
              for (final p in _priorities)
                DropdownMenuItem(value: p, child: Text(p)),
            ],
            onChanged: (v) => setState(() => _priority = v ?? 'NORMAL'),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: const Text('Due date'),
            subtitle: Text(
                _dueAt == null ? 'No deadline' : _formatDate(_dueAt!)),
            trailing: _dueAt == null
                ? TextButton(onPressed: _pickDueDate, child: const Text('Set'))
                : IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear due date',
                    onPressed: () => setState(() => _dueAt = null),
                  ),
            onTap: _pickDueDate,
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save'),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.event});

  final ActivityEventRef event;

  @override
  Widget build(BuildContext context) {
    final subtitle = activitySubtitle(event);
    final messages = _messagesFrom(event.detail);
    // Scalar detail fields (everything except the transcript, which renders
    // as a conversation below).
    final detailEntries =
        event.detail.entries.where((e) => e.key != 'messages').toList();
    final hasTranscript = messages.isNotEmpty;
    final subtitleText = [
      if (subtitle != null) subtitle,
      if (hasTranscript) '${messages.length} messages — tap to read',
    ].join(' · ');
    return ExpansionTile(
      dense: true,
      leading: Icon(activityIcon(event.kind), size: 20),
      title: Text(activityTitle(event)),
      subtitle: subtitleText.isEmpty ? null : Text(subtitleText),
      trailing: Text(
        activityTime(event.at),
        style: Theme.of(context).textTheme.labelSmall,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        for (final entry in detailEntries)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text('${entry.key}: ${entry.value}',
                  style: Theme.of(context).textTheme.labelSmall),
            ),
          ),
        if (hasTranscript) ...[
          const SizedBox(height: 6),
          for (final m in messages) _TranscriptTurn(turn: m),
        ],
      ],
    );
  }
}

List<Map<String, dynamic>> _messagesFrom(Map<String, dynamic> detail) {
  final m = detail['messages'];
  if (m is List) {
    return m
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList(growable: false);
  }
  return const [];
}

/// _TranscriptTurn renders one LLM message — a role-tinted card with the
/// content (selectable) and any tool calls the model proposed.
class _TranscriptTurn extends StatelessWidget {
  const _TranscriptTurn({required this.turn});

  final Map<String, dynamic> turn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final role = (turn['role'] ?? '').toString();
    final content = (turn['content'] ?? '').toString();
    final toolCalls = turn['tool_calls'];

    final Color bg;
    switch (role) {
      case 'assistant':
        bg = scheme.primaryContainer;
        break;
      case 'user':
        bg = scheme.secondaryContainer;
        break;
      case 'tool_result':
        bg = scheme.tertiaryContainer;
        break;
      default: // system
        bg = scheme.surfaceContainerHighest;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 2),
            SelectableText(content,
                style: Theme.of(context).textTheme.bodySmall),
          ],
          if (toolCalls is List)
            for (final tc in toolCalls.whereType<Map>())
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.build, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${tc['name']}(${tc['payload'] ?? ''})',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _Findings extends StatelessWidget {
  const _Findings({required this.findings});

  final Map<String, dynamic> findings;

  @override
  Widget build(BuildContext context) {
    final freeText = findings['free_text'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (freeText is String && freeText.isNotEmpty) Text(freeText),
            if (freeText is String && freeText.isNotEmpty)
              const SizedBox(height: 6),
            for (final entry in findings.entries)
              if (entry.key != 'free_text')
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('${entry.key}: ${entry.value}',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
