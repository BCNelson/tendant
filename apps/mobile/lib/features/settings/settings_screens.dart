import 'package:built_value/json_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/graphql/client.dart';
import '../../core/graphql/ferry_helpers.dart';
import '../../core/server/server_address.dart';
import '../../graphql/queries/__generated__/categories.req.gql.dart';
import '../../graphql/queries/__generated__/config.req.gql.dart';
import '../../graphql/queries/__generated__/connectors.req.gql.dart';

import 'categories/categories_page.dart';
import 'categories/category_models.dart';
import 'config/config_models.dart';
import 'config/config_page.dart';
import 'connectors/connector_models.dart';
import 'connectors/connectors_page.dart';

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

/// configKeysProvider loads the owner-only layered-config registry.
final configKeysProvider = FutureProvider<List<ConfigKeyView>>((ref) async {
  final client = ref.watch(ferryClientProvider);
  final data = await runOnceRequired(
    client,
    GConfigKeysReq(),
  );
  return [
    for (final k in data.configKeys)
      ConfigKeyView(
        key: k.key,
        type: k.type,
        description: k.description,
        reload: k.reload,
        sensitive: k.sensitive,
        dbConfigurable: k.dbConfigurable,
        hotReloadable: k.hotReloadable,
        readonlyReason: k.readonlyReason,
        defaultValue: k.defaultValue,
        effectiveValue: k.effectiveValue,
        overridden: k.overridden,
      ),
  ];
});

/// ConfigScreen fetches the config registry and renders [ConfigPage], wiring
/// the override/clear callbacks to the Ferry mutations.
class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(configKeysProvider);
    return async.when(
      loading: () => _loading('Configuration'),
      error: (e, _) => _error('Configuration', e),
      data: (keys) => ConfigPage(
        keys: keys,
        onSet: (key, value) => _run(
          context,
          ref,
          () async {
            final client = ref.read(ferryClientProvider);
            await runOnceRequired(
              client,
              GSetConfigEntryReq((b) => b
                ..vars.key = key
                ..vars.value = value),
            );
          },
        ),
        onClear: (key) => _run(
          context,
          ref,
          () async {
            final client = ref.read(ferryClientProvider);
            await runOnceRequired(
              client,
              GDeleteConfigEntryReq((b) => b..vars.key = key),
            );
          },
        ),
      ),
    );
  }

  void _run(BuildContext context, WidgetRef ref, Future<void> Function() op) {
    op().then((_) {
      ref.invalidate(configKeysProvider);
    }).catchError((Object e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    });
  }
}

// ---------------------------------------------------------------------------
// Connectors
// ---------------------------------------------------------------------------

/// connectorsProvider loads the owner-only configured integrations.
final connectorsProvider = FutureProvider<List<ConnectorView>>((ref) async {
  final client = ref.watch(ferryClientProvider);
  final data = await runOnceRequired(
    client,
    GConnectorsReq(),
  );
  return [
    for (final c in data.connectors)
      ConnectorView(
        id: c.id,
        connectorType: c.connectorType,
        enabled: c.enabled,
        config: () {
          final raw = c.config.value;
          return raw is Map ? raw.cast<String, dynamic>() : <String, dynamic>{};
        }(),
      ),
  ];
});

/// ConnectorsScreen fetches connectors and renders [ConnectorsPage], wiring the
/// enable/disable switch to the Ferry mutation.
class ConnectorsScreen extends ConsumerWidget {
  const ConnectorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(connectorsProvider);
    return async.when(
      loading: () => _loading('Connectors'),
      error: (e, _) => _error('Connectors', e),
      data: (connectors) => ConnectorsPage(
        connectors: connectors,
        onToggleEnabled: (c, enabled) {
          ref
              .read(ferryClientProvider)
              .let((client) => runOnceRequired(
                    client,
                    GEnableConnectorReq((b) => b
                      ..vars.connectorId = c.id
                      ..vars.enabled = enabled),
                  ))
              .then((_) => ref.invalidate(connectorsProvider))
              .catchError((Object e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Failed: $e')));
            }
          });
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Task categories
// ---------------------------------------------------------------------------

/// categoriesProvider loads the owner-only task-category taxonomy, ordered by
/// key (parents before children) with a derived tree depth for indentation.
final categoriesProvider = FutureProvider<List<CategoryView>>((ref) async {
  final client = ref.watch(ferryClientProvider);
  final data = await runOnceRequired(
    client,
    GCategoriesReq(),
  );
  final views = [
    for (final c in data.categories)
      CategoryView(
        key: c.key,
        label: c.label,
        description: c.description,
        parentKey: c.parent?.key,
        stageBindings: () {
          final raw = c.stageBindings.value;
          return raw is Map ? raw.cast<String, dynamic>() : <String, dynamic>{};
        }(),
      ),
  ];
  return _withTreeDepth(views);
});

/// _withTreeDepth assigns each category a depth = number of ancestors in the
/// taxonomy, so the list can render an indented tree.
List<CategoryView> _withTreeDepth(List<CategoryView> views) {
  final parentOf = {for (final v in views) v.key: v.parentKey};
  int depthOf(String key) {
    var d = 0;
    var p = parentOf[key];
    final seen = <String>{key};
    while (p != null && p.isNotEmpty && seen.add(p)) {
      d++;
      p = parentOf[p];
    }
    return d;
  }

  return [for (final v in views) v.withDepth(depthOf(v.key))];
}

/// CategoriesScreen fetches the taxonomy and renders [CategoriesPage], wiring the
/// upsert/delete callbacks to the owner-only Ferry mutations.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(categoriesProvider);
    return async.when(
      loading: () => _loading('Task Categories'),
      error: (e, _) => _error('Task Categories', e),
      data: (categories) => CategoriesPage(
        categories: categories,
        onSave: (edit) => _run(
          context,
          ref,
          () async {
            final client = ref.read(ferryClientProvider);
            await runOnceRequired(
              client,
              GSetTaskCategoryReq((b) {
                b.vars.input.key = edit.key;
                if (edit.label != null) b.vars.input.label = edit.label;
                if (edit.description != null) {
                  b.vars.input.description = edit.description;
                }
                if (edit.parent != null) b.vars.input.parent = edit.parent;
                if (edit.stageBindings != null) {
                  b.vars.input.stageBindings = JsonObject(edit.stageBindings!);
                }
              }),
            );
          },
        ),
        onDelete: (key) => _run(
          context,
          ref,
          () async {
            final client = ref.read(ferryClientProvider);
            await runOnceRequired(
              client,
              GDeleteTaskCategoryReq((b) => b..vars.key = key),
            );
          },
        ),
      ),
    );
  }

  void _run(BuildContext context, WidgetRef ref, Future<void> Function() op) {
    op().then((_) {
      ref.invalidate(categoriesProvider);
    }).catchError((Object e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    });
  }
}

// ---------------------------------------------------------------------------
// Settings home
// ---------------------------------------------------------------------------

/// SettingsHomePage is the owner settings hub linking to the config + connector
/// surfaces. Reached from the inbox AppBar.
class SettingsHomePage extends ConsumerWidget {
  const SettingsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final server = ref.watch(serverAddressProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: const Text('Server address'),
            subtitle: Text(server.baseUrl == null
                ? 'Not configured'
                : '${server.baseUrl} · ${server.sourceLabel}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/server'),
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Configuration'),
            subtitle: const Text('Layered config registry & overrides'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/config'),
          ),
          ListTile(
            leading: const Icon(Icons.cable_outlined),
            title: const Text('Connectors'),
            subtitle: const Text('Configured intake integrations'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/connectors'),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Task Categories'),
            subtitle: const Text('Taxonomy & per-stage agent routing'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/categories'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared scaffolds
// ---------------------------------------------------------------------------

Widget _loading(String title) => Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: CircularProgressIndicator()),
    );

Widget _error(String title, Object e) => Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Error: $e')),
    );

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
