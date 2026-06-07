import 'package:flutter/material.dart';

/// PromotionProposalView is the read-only view-model for a `PromotionProposal`
/// PendingDecision (Phase 8). Hydration from generated Ferry queries lives in
/// the bootstrap layer (mirroring approval_models.dart / overseer_evaluation).
class PromotionProposalView {
  const PromotionProposalView({
    required this.id,
    required this.toolName,
    required this.toolGlobalUri,
    required this.fromLevel,
    required this.toLevel,
    required this.routine,
    required this.maturedClean,
    required this.windowN,
    required this.ratio,
  });

  final String id;
  final String toolName;
  final String toolGlobalUri;
  final String fromLevel;
  final String toLevel;
  final String routine;
  final int maturedClean;
  final int windowN;
  final double ratio;
}

/// PromotionProposalCard renders a tool's earned-autonomy proposal — the band
/// crossing the owner consents to plus the legible track-record evidence — and
/// exposes Accept / Decline, which call `respondToPromotion`. Mirrors the
/// Phase-4 OverseerEvaluationCard pattern; the owner is the only principal who
/// can raise autonomy (Constitution IV).
class PromotionProposalCard extends StatelessWidget {
  const PromotionProposalCard({
    super.key,
    required this.proposal,
    this.onAccept,
    this.onDecline,
    this.busy = false,
  });

  final PromotionProposalView proposal;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final bool busy;

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
                Icon(Icons.trending_up, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text('Promotion proposal', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(proposal.toolName, style: theme.textTheme.titleSmall),
            SelectableText(proposal.toolGlobalUri,
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text(proposal.fromLevel)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward, size: 16),
                ),
                Chip(
                  label: Text(proposal.toLevel),
                  backgroundColor: Colors.green.shade700.withAlpha(40),
                  labelStyle: TextStyle(color: Colors.green.shade700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Routine: ${proposal.routine}',
                style: theme.textTheme.bodyMedium),
            Text(
              'Clean ${proposal.maturedClean} of the last ${proposal.windowN} '
              '(${(proposal.ratio * 100).toStringAsFixed(0)}%)',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: busy ? null : onDecline,
                  child: const Text('Decline'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: busy ? null : onAccept,
                  child: const Text('Grant autonomy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
