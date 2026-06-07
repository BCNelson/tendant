import 'package:flutter/material.dart';

/// ProvenanceCard renders an intake-origin task's provenance on the task-detail
/// page (SC-006): the source reference (`raw_ref`) and the human-readable
/// reason the connector flagged it. Shown only when `Task.provenance` is
/// non-null (owner-authored tasks have no provenance).
///
/// Provenance is a reference, never a content copy — `raw_ref` is a source-stable
/// id (e.g. "gmail:message/<id>", "rss:<feed>#<guid>") the connector re-fetches
/// on demand for detail view.
class ProvenanceCard extends StatelessWidget {
  const ProvenanceCard({super.key, required this.provenance});

  /// The decoded `Task.provenance` JSON map ({raw_ref, reason}). Null/empty ⇒
  /// the card renders nothing (owner-authored task).
  final Map<String, dynamic>? provenance;

  @override
  Widget build(BuildContext context) {
    final p = provenance;
    if (p == null || p.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final rawRef = (p['raw_ref'] ?? '').toString();
    final reason = (p['reason'] ?? '').toString();

    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inbox_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Where this came from', style: theme.textTheme.titleMedium),
                const Spacer(),
                const Chip(
                  label: Text('Intake'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(reason, style: theme.textTheme.bodyMedium),
            ],
            if (rawRef.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Source', style: theme.textTheme.labelMedium),
              const SizedBox(height: 2),
              SelectableText(rawRef, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
