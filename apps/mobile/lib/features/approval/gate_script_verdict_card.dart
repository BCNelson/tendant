import 'package:flutter/material.dart';

import '../gate_script/gate_script_models.dart';

/// GateScriptVerdictCard renders a gate script's verdict + evidence on the
/// ApprovalDetailPage — shown only when the parent
/// `ApprovalRequest.gateScriptEvaluation` is non-null (the script, not the floor
/// or overseer, escalated). Visually differentiated from OverseerEvaluationCard
/// by icon + a "Source: Gate script" label so the operator sees who escalated:
/// deterministic script evidence vs. LLM judgment.
class GateScriptVerdictCard extends StatelessWidget {
  const GateScriptVerdictCard({super.key, required this.eval});

  final GateScriptVerdictView eval;

  Color _verdictColor(BuildContext context) {
    switch (eval.verdict) {
      case 'approve':
        return Colors.green.shade700;
      case 'deny':
        return Colors.red.shade700;
      case 'request_decision':
        return Colors.orange.shade800;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _verdictColor(context);
    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // terminal/deterministic icon — distinct from the overseer's policy icon.
                Icon(Icons.terminal, color: color),
                const SizedBox(width: 8),
                Text('Gate script', style: theme.textTheme.titleMedium),
                const Spacer(),
                Chip(
                  label: Text(eval.verdict),
                  backgroundColor: color.withAlpha(40),
                  labelStyle: TextStyle(color: color),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Source: Gate script (deterministic)  ·  v${eval.scriptVersion}',
                style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            Text(eval.summary, style: theme.textTheme.bodyMedium),
            if (eval.consideredFields.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: eval.consideredFields
                    .map((f) => Chip(
                          label: Text(f),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
            if (eval.hostcallTrace.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Host calls', style: theme.textTheme.labelMedium),
              const SizedBox(height: 2),
              ...eval.hostcallTrace.map(
                (h) => Text('• $h', style: theme.textTheme.bodySmall),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
