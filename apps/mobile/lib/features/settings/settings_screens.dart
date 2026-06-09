import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/graphql/client.dart';
import '../../core/graphql/ferry_helpers.dart';
import '../../core/server/server_address.dart';
import '../../graphql/queries/__generated__/config.req.gql.dart';
import '../../graphql/queries/__generated__/connectors.req.gql.dart';

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
    GConfigKeysReq((b) => b..fetchPolicy = FetchPolicy.NetworkOnly),
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
    GConnectorsReq((b) => b..fetchPolicy = FetchPolicy.NetworkOnly),
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
