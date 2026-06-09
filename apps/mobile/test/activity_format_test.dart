import 'package:flutter_test/flutter_test.dart';

import 'package:tendant/features/tasks/activity_format.dart';
import 'package:tendant/features/tasks/tasks_models.dart';

ActivityEventRef _ev(String kind, Map<String, dynamic> detail) =>
    ActivityEventRef(
      id: 'x',
      kind: kind,
      at: '2026-06-09T03:02:07Z',
      actor: 'system',
      detail: detail,
    );

void main() {
  test('agent run finished shows specialist + tokens', () {
    final e = _ev('agent_run_finished', {
      'config_name': 'general-triager',
      'stage': 'triage',
      'iterations': 1,
      'tokens_in': 126,
      'tokens_out': 101,
    });
    expect(activityTitle(e), 'general-triager finished');
    expect(activitySubtitle(e), '1 iter · 126+101 tok');
  });

  test('stage advance reads from/to + reason', () {
    final e = _ev('stage_advance',
        {'from': 'triage', 'to': 'expansion', 'reason': 'genesis'});
    expect(activityTitle(e), 'Stage: triage → expansion');
    expect(activitySubtitle(e), 'genesis');
  });

  test('decision resolved reflects approval', () {
    expect(activityTitle(_ev('decision_resolved', {'approved': true})),
        'Approved');
    expect(activityTitle(_ev('decision_resolved', {'approved': false})),
        'Rejected');
  });

  test('tool dispatch surfaces an error', () {
    final e = _ev('tool_dispatched', {'provider': 'smtp', 'error': 'timeout'});
    expect(activityTitle(e), 'Tool dispatch failed');
    expect(activitySubtitle(e), 'timeout');
  });

  test('unknown kind falls back to spaced kind', () {
    expect(activityTitle(_ev('some_new_kind', {})), 'some new kind');
  });

  test('activityTime renders local HH:mm:ss or falls back', () {
    expect(activityTime('not-a-date'), 'not-a-date');
    expect(activityTime('2026-06-09T03:02:07Z').length, 8); // HH:mm:ss
  });
}
