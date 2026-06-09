import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/session_store.dart';
import '../../core/server/server_address.dart';

/// ServerAddressPage is the first-launch screen (before pairing) that asks for
/// the tendant server address, and doubles as the settings editor for it.
///
/// When the address was supplied by an override channel (build define, env
/// var, config file, or — on web — the page origin) it renders read-only with
/// the source noted; otherwise it offers an editable field. Saving a new
/// address clears any existing session (tokens are server-scoped) and routes
/// to pairing.
class ServerAddressPage extends ConsumerStatefulWidget {
  const ServerAddressPage({super.key});

  @override
  ConsumerState<ServerAddressPage> createState() => _ServerAddressPageState();
}

class _ServerAddressPageState extends ConsumerState<ServerAddressPage> {
  late final TextEditingController _url;
  String? _error;
  bool _busy = false;
  String? _statusLine; // progress text shown while probing
  String? _unreachable; // primary candidate that failed detection (save-anyway)

  @override
  void initState() {
    super.initState();
    final current = ref.read(serverAddressProvider);
    _url = TextEditingController(
      text: current.source == ServerAddressSource.userEntered
          ? (current.baseUrl ?? '')
          : '',
    );
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  /// _connect expands the input into candidate origins, probes each `/healthz`,
  /// and commits the first that answers. If none answer it offers save-anyway.
  Future<void> _connect() async {
    final candidates = serverUrlCandidates(_url.text);
    if (candidates.isEmpty) {
      setState(() => _error = 'Enter a valid address, e.g. localhost:8080');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _unreachable = null;
      _statusLine = 'Looking for a tendant server…';
    });
    try {
      final found = await detectServer(candidates);
      if (found != null) {
        await _commit(found);
        return;
      }
      // Nothing answered — keep the user's primary guess and let them force it
      // (server may be down, behind auth, or healthz blocked by a proxy).
      if (mounted) {
        setState(() {
          _unreachable = candidates.first;
          _statusLine = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _statusLine = null);
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// _commit persists [base], updates the provider, and routes onward. A change
  /// of server invalidates the (server-scoped) session, so it is cleared.
  Future<void> _commit(String base) async {
    final previous = ref.read(serverAddressProvider).baseUrl;
    await ref.read(serverAddressStoreProvider).write(base);
    ref.read(serverAddressProvider.notifier).state = ResolvedServerAddress(
      baseUrl: base,
      source: ServerAddressSource.userEntered,
    );
    if (previous != null && previous != base) {
      await ref.read(sessionStoreProvider).clear();
      ref.read(sessionTokenProvider.notifier).state = null;
    }
    if (!mounted) return;
    final paired = ref.read(sessionTokenProvider) != null;
    context.go(paired ? '/inbox' : '/pairing');
  }

  Future<void> _saveAnyway() async {
    final base = _unreachable;
    if (base == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _commit(base);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(serverAddressProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Server address')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: current.locked
            ? _LockedView(address: current)
            : _editor(context),
      ),
    );
  }

  Widget _editor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter the address of your tendant server.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _url,
          keyboardType: TextInputType.url,
          autocorrect: false,
          enableSuggestions: false,
          onChanged: (_) {
            if (_unreachable != null || _error != null) {
              setState(() {
                _unreachable = null;
                _error = null;
              });
            }
          },
          decoration: const InputDecoration(
            labelText: 'Server address',
            hintText: 'localhost:8080  •  https://tendant.example.com',
            helperText: 'Host, host:port, or full URL — scheme, port, and any '
                '/graphql path are filled in and verified automatically.',
            helperMaxLines: 3,
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _busy ? null : _connect(),
        ),
        const SizedBox(height: 16),
        if (_statusLine != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(_statusLine!)),
              ],
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        if (_unreachable != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              "Couldn't reach a tendant server at $_unreachable. "
              'Check the address, or save it anyway if the server is offline.',
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        FilledButton(
          onPressed: _busy ? null : _connect,
          child: Text(_busy ? 'Connecting…' : 'Connect'),
        ),
        if (_unreachable != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton(
              onPressed: _busy ? null : _saveAnyway,
              child: const Text('Save anyway'),
            ),
          ),
        const SizedBox(height: 24),
        const Text(
          'This can also be set without this screen:\n'
          '• Build time:  --dart-define=TENDANT_SERVER_URL=…\n'
          '• Native env:  TENDANT_SERVER_URL=…\n'
          '• Config file: server_url in '
          '\$XDG_CONFIG_HOME/tendant/client.toml\n'
          '• Web:         uses the serving host automatically',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

/// _LockedView shows the resolved address when it came from an override
/// channel and cannot be edited from the app.
class _LockedView extends StatelessWidget {
  const _LockedView({required this.address});

  final ResolvedServerAddress address;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(address.baseUrl ?? '—'),
            subtitle: Text(address.sourceLabel),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'The server address is set by your deployment and cannot be '
          'changed here. Update the override (build define, environment '
          'variable, or config file) to point at a different server.',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }
}
