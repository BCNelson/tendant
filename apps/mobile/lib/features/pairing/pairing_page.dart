import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/session_store.dart';

/// PairingPage is the first-launch screen: paste in the setup secret, name
/// the device, hit Pair. On success the bearer is persisted and we route to
/// /inbox.
class PairingPage extends ConsumerStatefulWidget {
  const PairingPage({super.key});

  @override
  ConsumerState<PairingPage> createState() => _PairingPageState();
}

class _PairingPageState extends ConsumerState<PairingPage> {
  final _secret = TextEditingController();
  final _name = TextEditingController();
  String? _error;
  bool _pairing = false;

  @override
  void dispose() {
    _secret.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _pair() async {
    final secret = _secret.text.trim();
    final name = _name.text.trim();
    if (secret.isEmpty || name.isEmpty) {
      setState(() => _error = 'Both fields are required.');
      return;
    }
    setState(() {
      _pairing = true;
      _error = null;
    });
    try {
      // Hand off to the Ferry client — generated PairDevice op lands in
      // T065. For now the page is a UI shell wired to a Riverpod hook the
      // operation file will populate.
      final token = await ref.read(pairDeviceProvider.future).then(
            (fn) => fn(secret: secret, displayName: name),
          );
      await ref.read(sessionStoreProvider).write(token);
      ref.read(sessionTokenProvider.notifier).state = token;
      if (mounted) context.go('/inbox');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _pairing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pair device')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _secret,
              decoration: const InputDecoration(
                labelText: 'Setup secret',
                helperText: 'From your tendant deployment',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Device name'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            FilledButton(
              onPressed: _pairing ? null : _pair,
              child: Text(_pairing ? 'Pairing…' : 'Pair'),
            ),
          ],
        ),
      ),
    );
  }
}

/// pairDeviceProvider is overridden by tests and wired against the Ferry
/// client + generated PairDevice operation at app boot.
typedef PairDeviceFn = Future<String> Function({
  required String secret,
  required String displayName,
});

final pairDeviceProvider = FutureProvider<PairDeviceFn>(
  (ref) async => ({required String secret, required String displayName}) async {
    throw UnimplementedError(
      'pairDeviceProvider not wired — override in main/app bootstrap',
    );
  },
);
