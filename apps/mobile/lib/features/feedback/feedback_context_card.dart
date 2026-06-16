import 'package:flutter/material.dart';

import 'feedback_models.dart';

/// FeedbackContextCard renders the read-only digest of what happened on the
/// completed task — the same context the feedback agent grounded its questions
/// and guidance in. Shown above the composer when a conversation carries a
/// non-empty [FeedbackContextView].
class FeedbackContextCard extends StatelessWidget {
  const FeedbackContextCard({super.key, required this.context});

  final FeedbackContextView context;

  /// Friendly labels for the read-only context tools the agent may consult.
  static const _toolLabels = <String, String>{
    'get_task_outcomes': 'Tool outcomes',
    'get_agent_transcript': 'Agent transcript',
    'get_task_audit': 'Audit trail',
    'get_existing_guidance': 'Existing guidance',
  };

  @override
  Widget build(BuildContext buildContext) {
    final theme = Theme.of(buildContext);
    final flaggedColor =
        context.toolsFlagged > 0 ? Colors.orange.shade800 : theme.colorScheme.primary;

    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fact_check_outlined, color: flaggedColor),
                const SizedBox(width: 8),
                Text('What happened on this task',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(context.summary, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _stat(theme, '${context.toolsRun} tool call(s)'),
                if (context.toolsFlagged > 0)
                  _stat(theme, '${context.toolsFlagged} flagged',
                      color: flaggedColor),
                for (final stage in context.agentStages) _stat(theme, stage),
                if (context.activeGuidanceCount > 0)
                  _stat(theme, '${context.activeGuidanceCount} active guidance'),
              ],
            ),
            if (context.handoffReason != null &&
                context.handoffReason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Handed off to a human: ${context.handoffReason}',
                  style: theme.textTheme.bodySmall),
            ],
            if (context.consulted.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Reviewed',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.outline)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: context.consulted
                    .map((t) => Chip(
                          avatar: const Icon(Icons.search, size: 16),
                          label: Text(_toolLabels[t] ?? t),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stat(ThemeData theme, String label, {Color? color}) => Chip(
        label: Text(label),
        labelStyle: color == null ? null : TextStyle(color: color),
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );
}
