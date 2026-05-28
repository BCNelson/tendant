import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/offline/connectivity.dart';
import '../../core/offline/floor_rail.dart';
import 'approval_models.dart';

/// ApprovalSubmissionResult is the outcome of a UI-driven submit. The
/// `refused` case indicates the floor rail rejected the action without
/// touching the network (offline + floor-relevant — Phase 2's
/// installed rail).
enum ApprovalSubmissionResult { ok, refusedOffline, serverError }

/// ApprovalMutator is the seam the UI calls to approve / reject. The
/// real Ferry implementation is wired in the bootstrap layer; tests
/// override this provider with an in-memory recorder.
abstract class ApprovalMutator {
  Future<ApprovalSubmissionResult> approve(String decisionId);
  Future<ApprovalSubmissionResult> reject(String decisionId, String? reason);
}

/// FloorAwareApprovalMutator wraps an inner mutator with the offline-rail
/// check. Phase 2 installed the rail; Phase 3 is the first phase where
/// real floor-relevant actions exist.
class FloorAwareApprovalMutator implements ApprovalMutator {
  FloorAwareApprovalMutator({
    required this.inner,
    required this.isOnline,
  });

  final ApprovalMutator inner;
  final bool Function() isOnline;

  @override
  Future<ApprovalSubmissionResult> approve(String decisionId) {
    if (_refuseOffline('approveArtifact')) {
      return Future.value(ApprovalSubmissionResult.refusedOffline);
    }
    return inner.approve(decisionId);
  }

  @override
  Future<ApprovalSubmissionResult> reject(String decisionId, String? reason) {
    if (_refuseOffline('rejectApproval')) {
      return Future.value(ApprovalSubmissionResult.refusedOffline);
    }
    return inner.reject(decisionId, reason);
  }

  bool _refuseOffline(String mutationName) {
    return classify(mutationName) == WriteClass.floorRelevant && !isOnline();
  }
}

/// approvalMutatorProvider is overridden by the bootstrap layer with the
/// FloorAwareApprovalMutator wired to a real Ferry client. The default
/// returns a no-op stub so widgets compile and tests can override.
final approvalMutatorProvider = Provider<ApprovalMutator>((ref) {
  return _NoopMutator();
});

class _NoopMutator implements ApprovalMutator {
  @override
  Future<ApprovalSubmissionResult> approve(String decisionId) async =>
      ApprovalSubmissionResult.serverError;
  @override
  Future<ApprovalSubmissionResult> reject(String decisionId, String? reason) async =>
      ApprovalSubmissionResult.serverError;
}

/// approvalRequestProvider is the per-decision detail loader. Overridden
/// by the bootstrap layer with a Ferry query that fetches one
/// PendingDecision by id and assembles an ApprovalRequestView.
final approvalRequestProvider =
    FutureProvider.family<ApprovalRequestView?, String>((ref, _) async => null);

/// onlineProvider is a tiny adapter so the FloorAwareApprovalMutator can
/// be wired from connectivityProvider in one line.
final onlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).valueOrNull ?? false;
});
