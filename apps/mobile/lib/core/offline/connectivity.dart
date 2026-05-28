import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// connectivityProvider emits true (online) / false (offline) on every
/// transition reported by connectivity_plus. The outbox flush listens.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final c = Connectivity();
  final initial = await c.checkConnectivity();
  yield _isOnline(initial);
  yield* c.onConnectivityChanged.map(_isOnline);
});

bool _isOnline(List<ConnectivityResult> results) {
  for (final r in results) {
    if (r != ConnectivityResult.none) return true;
  }
  return false;
}
