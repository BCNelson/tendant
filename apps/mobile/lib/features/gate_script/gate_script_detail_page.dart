import 'package:flutter/material.dart';

import 'gate_script_models.dart';

/// GateScriptDetailPage is the read-only view of a tool's active gate script
/// (FR-040), reachable from ToolDetailPage. It renders version, tier, attach
/// metadata, manifest hash, and the syntax-ish source when present. It NEVER
/// renders the wasm bytes. There is no editor in Phase 5 — owners author via
/// the GraphQL mutations.
class GateScriptDetailPage extends StatelessWidget {
  const GateScriptDetailPage({super.key, required this.script});

  final GateScriptDetailView script;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Gate script')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _row(theme, 'Version', 'v${script.version}'),
          _row(theme, 'Tier', _tierLabel(script.tier)),
          _row(theme, 'Status', script.status),
          _row(theme, 'Attached by', script.attachedByPrincipal),
          _row(theme, 'Attached at', script.attachedAt.toIso8601String()),
          _row(theme, 'Manifest hash', script.manifestHash),
          const SizedBox(height: 16),
          if (script.source != null) ...[
            Text('Source', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                script.source!,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ] else
            Text(
              'No source — this is a BYO .wasm (Tier 2) script.',
              style: theme.textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }

  static String _tierLabel(String tier) {
    switch (tier) {
      case 'ASSEMBLYSCRIPT_IN_APP':
        return 'AssemblyScript (in-app compiled)';
      case 'BYO_WASM':
        return 'BYO .wasm';
      default:
        return tier;
    }
  }

  Widget _row(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.labelLarge),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
