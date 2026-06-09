import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; // StateProvider moved here in riverpod 3
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'native_env.dart' if (dart.library.io) 'native_env_io.dart';

/// _buildTimeServerUrl is the compile-time override, set with
/// `flutter build --dart-define=TENDANT_SERVER_URL=https://host`. Empty when
/// not provided. This is the highest-precedence channel after the web origin.
const String _buildTimeServerUrl =
    String.fromEnvironment('TENDANT_SERVER_URL');

/// ServerAddressSource records which channel supplied the resolved address.
/// The ordering of the enum mirrors the resolution precedence (highest first).
enum ServerAddressSource {
  /// Served by the API itself — the address is the page origin (web only).
  web,

  /// `--dart-define=TENDANT_SERVER_URL` baked in at build time.
  buildDefine,

  /// `TENDANT_SERVER_URL` process env var (native).
  envVar,

  /// `server_url` in the XDG/OS client config file (native desktop).
  configFile,

  /// Entered by the user on the server-address screen and persisted.
  userEntered,

  /// Nothing configured yet — the app must prompt for an address.
  unset,
}

/// ResolvedServerAddress is the outcome of [ServerAddressResolver]: the base
/// origin (`scheme://host[:port]`, no path) and where it came from.
class ResolvedServerAddress {
  const ResolvedServerAddress({required this.baseUrl, required this.source});

  const ResolvedServerAddress.unset()
      : baseUrl = null,
        source = ServerAddressSource.unset;

  /// The normalized base origin, or null when [source] is [unset].
  final String? baseUrl;
  final ServerAddressSource source;

  bool get isConfigured => baseUrl != null;

  /// locked is true when the address came from a non-interactive override
  /// channel: the user can view it but not edit it from the app.
  bool get locked =>
      source == ServerAddressSource.web ||
      source == ServerAddressSource.buildDefine ||
      source == ServerAddressSource.envVar ||
      source == ServerAddressSource.configFile;

  /// sourceLabel is a short human description for the settings/edit screen.
  String get sourceLabel {
    switch (source) {
      case ServerAddressSource.web:
        return 'Served by this host';
      case ServerAddressSource.buildDefine:
        return 'Set at build time (--dart-define)';
      case ServerAddressSource.envVar:
        return 'TENDANT_SERVER_URL env var';
      case ServerAddressSource.configFile:
        return 'Client config file';
      case ServerAddressSource.userEntered:
        return 'Entered on this device';
      case ServerAddressSource.unset:
        return 'Not configured';
    }
  }
}

/// normalizeServerBaseUrl turns loose user/config input into a canonical base
/// origin (`scheme://host[:port]`), or null when it has no host. A missing
/// scheme defaults to `http`; any path (e.g. a pasted `/graphql`), query, or
/// trailing slash is dropped. Returns [serverUrlCandidates]`.first`.
String? normalizeServerBaseUrl(String input) {
  final candidates = serverUrlCandidates(input);
  return candidates.isEmpty ? null : candidates.first;
}

final RegExp _schemeRe = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://');

bool _isLocalHost(String host) {
  final h = host.toLowerCase();
  return h == 'localhost' ||
      h == '127.0.0.1' ||
      h == '::1' ||
      h == '0.0.0.0' ||
      h.endsWith('.local') ||
      h.startsWith('10.') ||
      h.startsWith('192.168.') ||
      RegExp(r'^172\.(1[6-9]|2[0-9]|3[01])\.').hasMatch(h);
}

/// serverUrlCandidates expands loose input into an ordered, de-duplicated list
/// of base origins to probe — generous in what it accepts:
///
///   `localhost`            → http://localhost:8080, http://localhost, https://…
///   `example.com`          → https://example.com, https://example.com:8080, http://…
///   `example.com/graphql`  → path stripped
///   `https://h:8443`       → scheme + port honored exactly (no guessing)
///   `[::1]:8080`           → IPv6 bracketed correctly
///
/// Heuristics: an explicit scheme/port is honored as-is; otherwise we try both
/// schemes (http-first for local/private hosts, https-first for public ones)
/// and both the tendant default port `8080` and the scheme's implicit port.
List<String> serverUrlCandidates(String input) {
  final s = input.trim();
  if (s.isEmpty) return const [];

  final hasScheme = _schemeRe.hasMatch(s);
  final uri = Uri.tryParse(hasScheme ? s : 'http://$s');
  if (uri == null || uri.host.isEmpty) return const [];

  final host = uri.host;
  final hostPart = host.contains(':') ? '[$host]' : host; // bracket IPv6
  final explicitScheme = hasScheme ? uri.scheme.toLowerCase() : null;
  final explicitPort = uri.hasPort ? uri.port : null;
  final local = _isLocalHost(host);

  final schemes = explicitScheme != null
      ? [explicitScheme]
      : (local ? ['http', 'https'] : ['https', 'http']);
  // `null` => the scheme's implicit port (80/443, omitted from the URL).
  final ports = explicitPort != null
      ? <int?>[explicitPort]
      : (local ? <int?>[8080, null] : <int?>[null, 8080]);

  final out = <String>[];
  for (final scheme in schemes) {
    for (final port in ports) {
      final url = port == null
          ? '$scheme://$hostPart'
          : '$scheme://$hostPart:$port';
      if (!out.contains(url)) out.add(url);
    }
  }
  return out;
}

/// HealthProbe checks whether a tendant server is reachable at a base origin.
typedef HealthProbe = Future<bool> Function(String baseUrl);

/// detectServer probes [candidates] in order and returns the first base origin
/// whose `/healthz` answers, or null when none respond. The [probe] seam is
/// injectable for tests; it defaults to the platform [probeServerHealth].
Future<String?> detectServer(List<String> candidates,
    {HealthProbe? probe}) async {
  final p = probe ?? probeServerHealth;
  for (final c in candidates) {
    if (await p(c)) return c;
  }
  return null;
}

/// ServerAddressStore persists the user-entered address. It reuses
/// flutter_secure_storage (already a dependency); on platforms where the
/// backing store is unavailable (e.g. Linux desktop without libsecret) reads
/// and writes degrade to no-ops, and the env-var / config-file channels are
/// the intended path there.
class ServerAddressStore {
  const ServerAddressStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'tendant.server_url';

  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String url) async {
    try {
      await _storage.write(key: _key, value: url);
    } catch (_) {
      // Best-effort: the user re-enters next launch if persistence fails.
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {}
  }
}

/// ServerAddressResolver walks the precedence chain once at boot:
///   web origin > build define > env var > config file > saved user value.
class ServerAddressResolver {
  const ServerAddressResolver({ServerAddressStore? store})
      : store = store ?? const ServerAddressStore();

  final ServerAddressStore store;

  Future<ResolvedServerAddress> resolve() async {
    // 1. Web: the bundle is served by the API, so talk to its own origin.
    if (kIsWeb) {
      return ResolvedServerAddress(
        baseUrl: Uri.base.origin,
        source: ServerAddressSource.web,
      );
    }

    // 2. Build-time --dart-define.
    final built = normalizeServerBaseUrl(_buildTimeServerUrl);
    if (built != null) {
      return ResolvedServerAddress(
        baseUrl: built,
        source: ServerAddressSource.buildDefine,
      );
    }

    // 3. Runtime env var (native).
    final env = nativeEnvServerUrl();
    if (env != null) {
      final b = normalizeServerBaseUrl(env);
      if (b != null) {
        return ResolvedServerAddress(
            baseUrl: b, source: ServerAddressSource.envVar);
      }
    }

    // 4. XDG/OS client config file (native desktop).
    final cfg = await configFileServerUrl();
    if (cfg != null) {
      final b = normalizeServerBaseUrl(cfg);
      if (b != null) {
        return ResolvedServerAddress(
            baseUrl: b, source: ServerAddressSource.configFile);
      }
    }

    // 5. Previously saved user-entered value.
    final saved = await store.read();
    if (saved != null) {
      final b = normalizeServerBaseUrl(saved);
      if (b != null) {
        return ResolvedServerAddress(
            baseUrl: b, source: ServerAddressSource.userEntered);
      }
    }

    // 6. Nothing — the app prompts.
    return const ResolvedServerAddress.unset();
  }
}

/// serverAddressStoreProvider exposes the persistence seam (overridable in
/// tests).
final serverAddressStoreProvider =
    Provider<ServerAddressStore>((ref) => const ServerAddressStore());

/// serverAddressProvider holds the currently-resolved address. It is seeded
/// at boot via a ProviderScope override (see `main.dart` / `ferryOverrides`)
/// and updated in place when the user sets a new address on the screen.
final serverAddressProvider = StateProvider<ResolvedServerAddress>(
  (ref) => const ResolvedServerAddress.unset(),
);
