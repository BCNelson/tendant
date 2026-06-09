import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/auth/session_store.dart';
import 'core/bootstrap.dart';
import 'core/server/server_address.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase is optional during development on platforms without
    // google-services.json / GoogleService-Info.plist.
  }
  String? initialSession;
  try {
    initialSession = await const SessionStore().read();
  } catch (_) {
    // Secure storage may be unavailable on some desktop setups (no
    // libsecret/keyring). Fall back to unpaired rather than crashing.
    initialSession = null;
  }

  // Resolve the server address through the precedence chain (web origin >
  // build define > env var > config file > saved value). An unset result
  // routes the app onto the server-address screen.
  final serverAddress = await const ServerAddressResolver().resolve();

  runApp(
    ProviderScope(
      overrides: [
        serverAddressProvider.overrideWith((ref) => serverAddress),
        sessionTokenProvider.overrideWith((ref) => initialSession),
        ...ferryOverrides(),
      ],
      child: TendantApp(initialSession: initialSession),
    ),
  );
}
