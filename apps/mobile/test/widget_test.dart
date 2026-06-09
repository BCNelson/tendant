import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendant/app.dart';
import 'package:tendant/core/server/server_address.dart';

void main() {
  testWidgets('prompts for a server address when none is configured',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TendantApp(initialSession: null)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Server address'), findsWidgets);
  });

  testWidgets('boots to the pairing screen when a server is configured',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serverAddressProvider.overrideWith(
            (ref) => const ResolvedServerAddress(
              baseUrl: 'http://localhost:8080',
              source: ServerAddressSource.userEntered,
            ),
          ),
        ],
        child: const TendantApp(initialSession: null),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pair device'), findsOneWidget);
  });
}
