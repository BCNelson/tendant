import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tendant/features/gate_script/gate_script_detail_page.dart';
import 'package:tendant/features/gate_script/gate_script_models.dart';

void main() {
  testWidgets('renders Tier-1 script metadata + source, never wasm', (tester) async {
    final view = GateScriptDetailView(
      version: 3,
      tier: 'ASSEMBLYSCRIPT_IN_APP',
      status: 'ACTIVE',
      attachedByPrincipal: 'tendant://principals/owner',
      attachedAt: DateTime.utc(2026, 6, 1, 12),
      manifestHash: 'abc123',
      source: 'export function evaluate(): Verdict { return verdict.approve(); }',
    );

    await tester.pumpWidget(MaterialApp(home: GateScriptDetailPage(script: view)));

    expect(find.text('v3'), findsOneWidget);
    expect(find.text('AssemblyScript (in-app compiled)'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.textContaining('verdict.approve()'), findsOneWidget);
  });

  testWidgets('Tier-2 BYO wasm shows no-source note', (tester) async {
    final view = GateScriptDetailView(
      version: 1,
      tier: 'BYO_WASM',
      status: 'ACTIVE',
      attachedByPrincipal: 'tendant://principals/owner',
      attachedAt: DateTime.utc(2026, 6, 1, 12),
      manifestHash: 'def456',
      source: null,
    );

    await tester.pumpWidget(MaterialApp(home: GateScriptDetailPage(script: view)));

    expect(find.textContaining('BYO .wasm (Tier 2)'), findsOneWidget);
  });
}
