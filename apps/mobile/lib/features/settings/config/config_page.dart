import 'package:flutter/material.dart';

import 'config_models.dart';

/// ConfigPage is the owner-only layered-config settings list: it shows every
/// config key with its effective value (DB overlay > env > file > default) and
/// lets the owner override the DB-configurable ones. Purely presentational —
/// the `configKeys` query and `setConfigEntry` / `deleteConfigEntry` mutations
/// are driven by the bootstrap/Ferry layer and handed in via [keys] + [onSet] /
/// [onClear] (mirrors ConnectorsPage).
///
/// All underlying operations are owner-principal-only; a non-owner device never
/// reaches this page (the operator edge rejects with PERMISSION_DENIED).
class ConfigPage extends StatelessWidget {
  const ConfigPage({
    super.key,
    required this.keys,
    required this.onSet,
    required this.onClear,
  });

  final List<ConfigKeyView> keys;

  /// Persist an override for [key] to the raw scalar [value] (e.g. "0.95").
  final void Function(String key, String value) onSet;

  /// Remove a key's override, reverting it to env/file/default.
  final void Function(String key) onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Group by the leading section ("calibration.ratio" -> "calibration").
    final sections = <String, List<ConfigKeyView>>{};
    for (final k in keys) {
      final head = k.key.split('.').first;
      sections.putIfAbsent(head, () => []).add(k);
    }
    final sectionNames = sections.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Configuration')),
      body: keys.isEmpty
          ? Center(
              child: Text('No config keys', style: theme.textTheme.bodyMedium),
            )
          : ListView(
              children: [
                for (final name in sectionNames) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      name.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  for (final k in sections[name]!)
                    _ConfigTile(item: k, onSet: onSet, onClear: onClear),
                  const Divider(height: 1),
                ],
              ],
            ),
    );
  }
}

class _ConfigTile extends StatelessWidget {
  const _ConfigTile({
    required this.item,
    required this.onSet,
    required this.onClear,
  });

  final ConfigKeyView item;
  final void Function(String key, String value) onSet;
  final void Function(String key) onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = item.sensitive ? '••••••' : (item.effectiveValue ?? '');
    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text(item.key)),
          if (item.overridden)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Chip(
                label: const Text('overridden'),
                visualDensity: VisualDensity.compact,
                labelStyle: theme.textTheme.labelSmall,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.description, style: theme.textTheme.labelSmall),
          Text(
            'value: $value   ·   ${item.type}   ·   ${item.effect}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          if (!item.editable && item.readonlyReason != null)
            Text(
              item.readonlyReason!,
              style: theme.textTheme.labelSmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
      isThreeLine: true,
      trailing: item.editable
          ? IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Override',
              onPressed: () => _edit(context),
            )
          : const Icon(Icons.lock_outline, size: 18),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final controller = TextEditingController(
      text: item.sensitive ? '' : (item.effectiveValue ?? ''),
    );
    final action = await showDialog<_EditAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.key),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description, style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'value (${item.type})',
                hintText: item.defaultValue,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          if (item.overridden)
            TextButton(
              onPressed: () => Navigator.pop(ctx, const _EditAction.clear()),
              child: const Text('Clear override'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, _EditAction.save(controller.text.trim())),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (action == null) return;
    if (action.clear) {
      onClear(item.key);
    } else if (action.value != null && action.value!.isNotEmpty) {
      onSet(item.key, action.value!);
    }
  }
}

/// _EditAction is the result of the override dialog: save a value or clear.
class _EditAction {
  const _EditAction.save(this.value) : clear = false;
  const _EditAction.clear() : value = null, clear = true;

  final String? value;
  final bool clear;
}
