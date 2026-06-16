import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'create_task_provider.dart';

/// CreateTaskPage is the manual task-compose form: a required title plus an
/// optional description, submitted via the `createTask` mutation. On success
/// it routes back to /inbox (where the resulting assignment surfaces after a
/// refresh once the chain workflow advances the task to TRIAGE).
class CreateTaskPage extends ConsumerStatefulWidget {
  const CreateTaskPage({super.key});

  @override
  ConsumerState<CreateTaskPage> createState() => _CreateTaskPageState();
}

// The owner-set priorities, in ascending order. NORMAL is the default.
const _priorities = ['LOW', 'NORMAL', 'HIGH', 'URGENT'];

// Date-only display, e.g. "2026-06-09" (the picker captures a day, not a time).
String _formatDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

class _CreateTaskPageState extends ConsumerState<CreateTaskPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _rank = TextEditingController();
  String _priority = 'NORMAL';
  DateTime? _dueAt;
  DateTime? _startsAt;
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _rank.dispose();
    super.dispose();
  }

  Future<void> _pickDate(DateTime? current, ValueChanged<DateTime> onPicked) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    final description = _description.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'A title is required.');
      return;
    }
    final rankText = _rank.text.trim();
    double? rank;
    if (rankText.isNotEmpty) {
      rank = double.tryParse(rankText);
      if (rank == null) {
        setState(() => _error = 'Rank must be a number.');
        return;
      }
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final create = await ref.read(createTaskProvider.future);
      await create(
        title: title,
        description: description.isEmpty ? null : description,
        priority: _priority,
        dueAt: _dueAt,
        startsAt: _startsAt,
        rank: rank,
      );
      if (mounted) context.go('/inbox');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New task')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              textInputAction: TextInputAction.next,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _description,
              decoration: const InputDecoration(
                labelText: 'Description',
                helperText: 'Optional',
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
            ),
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
              subtitle: Text(_dueAt == null
                  ? 'Optional — no deadline'
                  : _formatDate(_dueAt!)),
              trailing: _dueAt == null
                  ? TextButton(
                      onPressed: () =>
                          _pickDate(_dueAt, (d) => setState(() => _dueAt = d)),
                      child: const Text('Set'),
                    )
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear due date',
                      onPressed: () => setState(() => _dueAt = null),
                    ),
              onTap: () => _pickDate(_dueAt, (d) => setState(() => _dueAt = d)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.play_circle_outline),
              title: const Text('Start date'),
              subtitle: Text(_startsAt == null
                  ? 'Optional — gates eligibility until then'
                  : _formatDate(_startsAt!)),
              trailing: _startsAt == null
                  ? TextButton(
                      onPressed: () => _pickDate(
                          _startsAt, (d) => setState(() => _startsAt = d)),
                      child: const Text('Set'),
                    )
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear start date',
                      onPressed: () => setState(() => _startsAt = null),
                    ),
              onTap: () =>
                  _pickDate(_startsAt, (d) => setState(() => _startsAt = d)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _rank,
              decoration: const InputDecoration(
                labelText: 'Rank',
                helperText: 'Optional — lower sorts first',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? 'Creating…' : 'Create task'),
            ),
          ],
        ),
      ),
    );
  }
}
