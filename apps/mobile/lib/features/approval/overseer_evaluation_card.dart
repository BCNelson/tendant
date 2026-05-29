import 'package:flutter/material.dart';

import 'approval_models.dart';

/// OverseerEvaluationCard renders the overseer's verdict + evidence above
/// the approve/reject buttons. Shown only when the parent
/// `ApprovalRequest.overseerEvaluation` is non-null.
class OverseerEvaluationCard extends StatelessWidget {
  const OverseerEvaluationCard({super.key, required this.eval});

  final OverseerEvaluationView eval;

  Color _verdictColor(BuildContext context) {
    switch (eval.verdict) {
      case 'approve':
        return Colors.green.shade700;
      case 'fail_closed_per_task_cap':
      case 'fail_closed_request_decision':
        return Colors.orange.shade800;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.policy, color: _verdictColor(context)),
                const SizedBox(width: 8),
                Text('Overseer evaluation',
                    style: theme.textTheme.titleMedium),
                const Spacer(),
                Chip(
                  label: Text(eval.verdict),
                  backgroundColor: _verdictColor(context).withAlpha(40),
                  labelStyle: TextStyle(color: _verdictColor(context)),
                ),
              ],
            ),
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
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${eval.provider} / ${eval.modelId}   '
              'in=${eval.tokensIn} out=${eval.tokensOut}   '
              '\$${eval.estimatedCostUsd.toStringAsFixed(5)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
