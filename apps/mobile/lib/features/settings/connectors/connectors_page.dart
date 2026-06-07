import 'package:flutter/material.dart';

import 'connector_models.dart';

/// ConnectorsPage is the owner-only Connectors settings list (Phase 7 / T055):
/// it lists configured integrations and lets the owner enable/disable each.
/// The page is purely presentational — the `connectors` query and the
/// enable/disable mutation are driven by the bootstrap/Ferry layer and handed
/// in via [connectors] + [onToggleEnabled] (mirrors ToolDetailPage's stance
/// that owner tuning wiring lives outside the widget).
///
/// All three underlying operations are owner-principal-only; a non-owner device
/// never reaches this page (the operator edge rejects with PERMISSION_DENIED).
class ConnectorsPage extends StatelessWidget {
  const ConnectorsPage({
    super.key,
    required this.connectors,
    required this.onToggleEnabled,
    this.onEditConfig,
  });

  final List<ConnectorView> connectors;

  /// Called when the owner flips a connector's enabled switch. Enabling a
  /// connector with no schedule is rejected server-side, so the switch is
  /// disabled when [ConnectorView.schedule] is null.
  final void Function(ConnectorView connector, bool enabled) onToggleEnabled;

  /// Optional hook to open a config editor for a connector.
  final void Function(ConnectorView connector)? onEditConfig;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Connectors')),
      body: connectors.isEmpty
          ? Center(
              child: Text('No connectors configured',
                  style: theme.textTheme.bodyMedium),
            )
          : ListView.separated(
              itemCount: connectors.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final c = connectors[i];
                final canEnable = (c.schedule ?? '').isNotEmpty;
                return ListTile(
                  leading: Icon(_iconFor(c.connectorType)),
                  title: Text(c.connectorType),
                  subtitle: Text(
                    canEnable
                        ? 'schedule: ${c.schedule}'
                        : 'no schedule — set one to enable',
                    style: theme.textTheme.labelSmall,
                  ),
                  trailing: Switch(
                    value: c.enabled,
                    onChanged: canEnable
                        ? (v) => onToggleEnabled(c, v)
                        : null,
                  ),
                  onTap: onEditConfig == null ? null : () => onEditConfig!(c),
                );
              },
            ),
    );
  }

  IconData _iconFor(String connectorType) {
    switch (connectorType) {
      case 'gmail':
      case 'imap':
        return Icons.mail_outline;
      case 'calendar':
        return Icons.calendar_today_outlined;
      case 'rss':
        return Icons.rss_feed;
      case 'webhook-in':
        return Icons.webhook_outlined;
      default:
        return Icons.cable_outlined;
    }
  }
}
