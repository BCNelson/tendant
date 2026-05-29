import 'package:flutter/material.dart';

/// ToolDetailView is the read-only view-model for the `Tool` GraphQL
/// type, scoped to what the Phase 4 detail page renders. Hydration from
/// generated Ferry queries lives in the bootstrap layer (mirroring
/// approval_models.dart).
class ToolDetailView {
  const ToolDetailView({
    required this.id,
    required this.name,
    required this.globalUri,
    this.overseerInstructions,
  });

  final String id;
  final String name;
  final String globalUri;
  final String? overseerInstructions;
}

/// ToolDetailPage is the minimal Phase 4 surface for a single Tool. The
/// owner tunes `overseerInstructions` and `permissions` via GraphQL
/// (FR-014); the mobile surface only displays them. A future phase can
/// add inline editors once the platform decides whether owner tuning
/// belongs on the operator-edge device at all.
class ToolDetailPage extends StatelessWidget {
  const ToolDetailPage({super.key, required this.tool});

  final ToolDetailView tool;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tool.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Global URI', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            SelectableText(tool.globalUri, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            Text('Overseer instructions',
                style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  tool.overseerInstructions ?? '(none)',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Read-only — tune via the operator GraphQL API.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
