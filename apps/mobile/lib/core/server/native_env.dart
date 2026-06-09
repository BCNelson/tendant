/// Web/stub implementation of the native override channels. On platforms
/// without `dart:io` (web, wasm) there is no process environment and no
/// filesystem config file, so both channels resolve to null — the server
/// address comes from the page origin (handled in [ServerAddressResolver])
/// or the user-entered value.
///
/// The `dart:io` variant lives in `native_env_io.dart` and is selected by the
/// conditional import in `server_address.dart`.
library;

/// nativeEnvServerUrl reads the `TENDANT_SERVER_URL` process env var. Always
/// null off-native.
String? nativeEnvServerUrl() => null;

/// configFileServerUrl reads the XDG (and OS-equivalent) client config file.
/// Always null off-native.
Future<String?> configFileServerUrl() async => null;

/// probeServerHealth GETs `<baseUrl>/healthz` to confirm a tendant server is
/// listening. Off-native there is no `dart:io` client; the web build resolves
/// its address from the page origin and never probes, so this is a no-op.
Future<bool> probeServerHealth(String baseUrl,
        {Duration timeout = const Duration(seconds: 4)}) async =>
    false;
