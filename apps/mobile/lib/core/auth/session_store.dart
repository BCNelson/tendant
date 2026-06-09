import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; // StateProvider moved here in riverpod 3
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kSessionKey = 'tendant.session_token';

/// SessionStore wraps flutter_secure_storage with the three operations the
/// pairing flow + auth_link need.
class SessionStore {
  const SessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> read() => _storage.read(key: _kSessionKey);

  Future<void> write(String token) =>
      _storage.write(key: _kSessionKey, value: token);

  Future<void> clear() => _storage.delete(key: _kSessionKey);
}

/// sessionTokenProvider holds the current bearer token. null = unpaired.
final sessionTokenProvider = StateProvider<String?>((ref) => null);

/// sessionStoreProvider exposes a SessionStore singleton.
final sessionStoreProvider = Provider<SessionStore>((ref) => const SessionStore());
