import 'package:flutter_test/flutter_test.dart';
import 'package:tendant/main.dart';

void main() {
  testWidgets('renders hello text', (tester) async {
    await tester.pumpWidget(const TendantApp());
    expect(find.text('Hello, tendant!'), findsOneWidget);
  });
}
