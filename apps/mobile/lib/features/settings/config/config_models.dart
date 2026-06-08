/// ConfigKeyView is the read view-model for the `ConfigKey` GraphQL type,
/// scoped to what the owner-only Config settings list renders. Hydration from
/// the generated Ferry `configKeys` query lives in the bootstrap layer
/// (mirroring ConnectorView / ToolDetailView).
class ConfigKeyView {
  const ConfigKeyView({
    required this.key,
    required this.type,
    required this.description,
    required this.reload,
    required this.sensitive,
    required this.dbConfigurable,
    required this.hotReloadable,
    this.readonlyReason,
    this.defaultValue,
    this.effectiveValue,
    required this.overridden,
  });

  final String key;
  final String type; // string | int | bool | duration | float64
  final String description;
  final String reload; // hot | restart | bootstrap
  final bool sensitive;
  final bool dbConfigurable;
  final bool hotReloadable;
  final String? readonlyReason;

  /// Stringified default / effective values. Null when the key is sensitive
  /// (redacted server-side).
  final String? defaultValue;
  final String? effectiveValue;

  /// True when a config_entries row overrides this key in the DB.
  final bool overridden;

  /// Whether the owner can edit this key from the UI right now.
  bool get editable => dbConfigurable;

  /// How a change takes effect, surfaced to the owner.
  String get effect {
    if (dbConfigurable && !hotReloadable && reload == 'hot') return 'restart';
    return reload;
  }
}
