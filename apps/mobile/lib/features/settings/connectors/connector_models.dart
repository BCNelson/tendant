/// ConnectorView is the read view-model for the `Connector` GraphQL type,
/// scoped to what the owner-only Connectors settings list renders. Hydration
/// from generated Ferry queries lives in the bootstrap layer (mirroring
/// tool_detail's ToolDetailView).
class ConnectorView {
  const ConnectorView({
    required this.id,
    required this.connectorType,
    required this.enabled,
    required this.config,
  });

  final String id;
  final String connectorType;
  final bool enabled;

  /// The decoded `config` JSON: connector_type, filter, schedule,
  /// disposition_rules. Credentials NEVER appear here (sealed server-side).
  final Map<String, dynamic> config;

  /// The cron schedule from config, or null when none is set (cannot enable).
  String? get schedule => config['schedule'] as String?;
}
