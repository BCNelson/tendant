/// Native (`dart:io`) implementation of the two override channels: the
/// `TENDANT_SERVER_URL` process env var and the XDG-style client config file.
/// Selected over `native_env.dart` by the conditional import in
/// `server_address.dart` whenever `dart:io` is available (mobile + desktop).
library;

import 'dart:convert';
import 'dart:io';

/// nativeEnvServerUrl returns the trimmed `TENDANT_SERVER_URL` env var, or
/// null when unset/blank. This is the runtime override for native apps.
String? nativeEnvServerUrl() {
  final v = Platform.environment['TENDANT_SERVER_URL'];
  if (v == null) return null;
  final t = v.trim();
  return t.isEmpty ? null : t;
}

/// configFileServerUrl looks for a `server_url` in the per-user client config
/// file, honoring XDG on Linux and the OS-equivalent dirs on macOS/Windows.
///
/// Search order (first existing file with a usable value wins):
///   $XDG_CONFIG_HOME/tendant/client.toml
///   $HOME/.config/tendant/client.toml                  (Linux/BSD fallback)
///   $HOME/Library/Application Support/tendant/client.toml   (macOS)
///   %APPDATA%\tendant\client.toml                      (Windows)
///
/// The file is a tiny TOML subset: a `server_url = "http://host:8080"` line
/// (quotes optional), `#` comments ignored. A file whose sole content is a
/// bare URL is also accepted.
Future<String?> configFileServerUrl() async {
  for (final path in _configCandidates()) {
    try {
      final file = File(path);
      if (!await file.exists()) continue;
      final parsed = parseServerUrlFromConfig(await file.readAsString());
      if (parsed != null) return parsed;
    } catch (_) {
      // Unreadable path (permissions, race) — fall through to the next.
    }
  }
  return null;
}

List<String> _configCandidates() {
  final env = Platform.environment;
  final home = env['HOME'];
  final out = <String>[];

  void add(String? dir) {
    if (dir == null || dir.isEmpty) return;
    out.add('$dir${Platform.pathSeparator}tendant'
        '${Platform.pathSeparator}client.toml');
  }

  add(env['XDG_CONFIG_HOME']);
  if (home != null && home.isNotEmpty) {
    add('$home${Platform.pathSeparator}.config');
    if (Platform.isMacOS) {
      add('$home/Library/Application Support');
    }
  }
  if (Platform.isWindows) add(env['APPDATA']);
  return out;
}

/// parseServerUrlFromConfig extracts a `server_url` value from the client
/// config file body. Exposed for unit tests. Returns null when no value is
/// found. A `server_url = ...` key wins over a bare-URL line.
String? parseServerUrlFromConfig(String content) {
  final keyLine = RegExp(r'^server_url\s*[=:]\s*(.+)$');
  String? bareUrl;
  for (final raw in const LineSplitter().convert(content)) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;

    final m = keyLine.firstMatch(line);
    if (m != null) {
      final value = _unquote(m.group(1)!.trim());
      if (value.isNotEmpty) return value;
      continue;
    }
    // A line that looks like a URL (and isn't a key=value) may be a bare
    // address — remember the first.
    if (bareUrl == null && line.contains('://') && !line.contains('=')) {
      bareUrl = _unquote(line);
    }
  }
  return bareUrl;
}

/// probeServerHealth GETs `<baseUrl>/healthz` and reports whether a *tendant*
/// server answered: a 2xx whose JSON body self-identifies via `service:
/// "tendant"`. A host that merely returns 200 (or some other service's health
/// payload) does not qualify. Any connection/TLS/timeout/parse failure
/// resolves to false so the caller falls through to the next candidate.
Future<bool> probeServerHealth(String baseUrl,
    {Duration timeout = const Duration(seconds: 4)}) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final req = await client.getUrl(Uri.parse('$baseUrl/healthz'));
    final resp = await req.close().timeout(timeout);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      await resp.drain<void>();
      return false;
    }
    final body = await resp.transform(utf8.decoder).join().timeout(timeout);
    return isTendantHealthzBody(body);
  } catch (_) {
    return false;
  } finally {
    client.close(force: true);
  }
}

/// isTendantHealthzBody confirms a `/healthz` body identifies a tendant server
/// (`service == "tendant"`). Exposed for unit tests.
bool isTendantHealthzBody(String body) {
  try {
    final decoded = jsonDecode(body);
    return decoded is Map && decoded['service'] == 'tendant';
  } catch (_) {
    return false;
  }
}

String _unquote(String s) {
  if (s.length >= 2 &&
      ((s.startsWith('"') && s.endsWith('"')) ||
          (s.startsWith("'") && s.endsWith("'")))) {
    return s.substring(1, s.length - 1);
  }
  return s;
}
