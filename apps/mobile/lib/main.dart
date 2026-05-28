import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/auth/session_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase is optional during development on platforms without
    // google-services.json / GoogleService-Info.plist.
  }
  final initialSession = await const SessionStore().read();
  runApp(
    ProviderScope(
      child: TendantApp(initialSession: initialSession),
    ),
  );
}
