import 'package:flutter_test/flutter_test.dart';

import 'package:tendant/features/approval/approval_provider.dart';

/// recordingMutator captures calls so we can assert the inner mutator was
/// (or wasn't) invoked.
class _RecordingMutator implements ApprovalMutator {
  int approveCalls = 0;
  int rejectCalls = 0;

  @override
  Future<ApprovalSubmissionResult> approve(String decisionId) async {
    approveCalls++;
    return ApprovalSubmissionResult.ok;
  }

  @override
  Future<ApprovalSubmissionResult> reject(String decisionId, String? reason) async {
    rejectCalls++;
    return ApprovalSubmissionResult.ok;
  }
}

void main() {
  group('FloorAwareApprovalMutator', () {
    test('refuses approveArtifact when offline (floor rail)', () async {
      final inner = _RecordingMutator();
      final mut = FloorAwareApprovalMutator(inner: inner, isOnline: () => false);

      final r = await mut.approve('decision-1');
      expect(r, ApprovalSubmissionResult.refusedOffline);
      expect(inner.approveCalls, 0, reason: 'inner must not be called when offline');
    });

    test('refuses rejectApproval when offline (floor rail)', () async {
      final inner = _RecordingMutator();
      final mut = FloorAwareApprovalMutator(inner: inner, isOnline: () => false);

      final r = await mut.reject('decision-1', 'too risky');
      expect(r, ApprovalSubmissionResult.refusedOffline);
      expect(inner.rejectCalls, 0);
    });

    test('passes through when online', () async {
      final inner = _RecordingMutator();
      final mut = FloorAwareApprovalMutator(inner: inner, isOnline: () => true);

      final r1 = await mut.approve('decision-1');
      expect(r1, ApprovalSubmissionResult.ok);
      expect(inner.approveCalls, 1);

      final r2 = await mut.reject('decision-1', null);
      expect(r2, ApprovalSubmissionResult.ok);
      expect(inner.rejectCalls, 1);
    });

    test('online status is re-evaluated on each call', () async {
      var online = true;
      final inner = _RecordingMutator();
      final mut = FloorAwareApprovalMutator(inner: inner, isOnline: () => online);

      expect(await mut.approve('d'), ApprovalSubmissionResult.ok);
      online = false;
      expect(await mut.approve('d'), ApprovalSubmissionResult.refusedOffline);
      expect(inner.approveCalls, 1, reason: 'second call should not reach inner');
    });
  });
}
