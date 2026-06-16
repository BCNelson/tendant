import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tendant/features/routing/routing_models.dart' show AgentStageView;
import 'package:tendant/features/tasks/tasks_models.dart';
import 'package:tendant/features/tasks/tasks_page.dart';

TaskRef _task({
  required String state,
  required String currentStage,
  List<TaskStageOccupancy> slots = const [],
}) =>
    TaskRef(
      id: 't1',
      shortId: 42,
      title: 'Call Mom',
      state: state,
      currentStage: currentStage,
      autonomy: 'NONE',
      hasOpenAssignment: false,
      stageSlots: slots,
    );

void main() {
  testWidgets('shows the working agent for the current stage', (tester) async {
    final task = _task(
      state: 'EXECUTING',
      currentStage: 'EXECUTION',
      slots: const [
        TaskStageOccupancy(
          stage: AgentStageView.execution,
          isHuman: false,
          occupantName: 'general-executor',
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TaskTile(task: task))),
    );

    expect(find.text('#42  Call Mom'), findsOneWidget);
    expect(find.text('EXECUTION · general-executor'), findsOneWidget);
    expect(find.text('EXECUTING'), findsOneWidget);
    // A running agent shows the robot icon.
    expect(find.byIcon(Icons.smart_toy), findsOneWidget);
  });

  testWidgets('shows "waiting on you" when the human holds the stage',
      (tester) async {
    final task = _task(
      state: 'WAITING',
      currentStage: 'TRIAGE',
      slots: const [
        TaskStageOccupancy(stage: AgentStageView.triage, isHuman: true),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TaskTile(task: task))),
    );

    expect(find.text('TRIAGE · waiting on you'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('terminal task shows the stage and a check icon', (tester) async {
    final task = _task(state: 'DONE', currentStage: 'COMPLETION');
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TaskTile(task: task))),
    );

    expect(find.text('COMPLETION'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.smart_toy), findsNothing);
  });
}
