import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'approval_models.dart';
import 'approval_provider.dart';

/// ApprovalDetailPage renders one ApprovalRequest's frozen Artifact and
/// exposes Approve / Reject actions. Both actions flow through the
/// FloorAwareApprovalMutator (Phase 2 floor rail) so offline submissions
/// are refused before they leave the device.
class ApprovalDetailPage extends ConsumerWidget {
  const ApprovalDetailPage({super.key, required this.decisionId});

  final String decisionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(approvalRequestProvider(decisionId));
    return Scaffold(
      appBar: AppBar(title: const Text('Approval')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (req) {
          if (req == null) {
            return const Center(child: Text('Approval request not found.'));
          }
          return _ApprovalBody(request: req);
        },
      ),
    );
  }
}

class _ApprovalBody extends ConsumerStatefulWidget {
  const _ApprovalBody({required this.request});

  final ApprovalRequestView request;

  @override
  ConsumerState<_ApprovalBody> createState() => _ApprovalBodyState();
}

class _ApprovalBodyState extends ConsumerState<_ApprovalBody> {
  bool _busy = false;

  Future<void> _approve() async {
    setState(() => _busy = true);
    final mutator = ref.read(approvalMutatorProvider);
    final result = await mutator.approve(widget.request.id);
    if (!mounted) return;
    setState(() => _busy = false);
    _showResult(result, approved: true);
  }

  Future<void> _reject() async {
    setState(() => _busy = true);
    final mutator = ref.read(approvalMutatorProvider);
    final result = await mutator.reject(widget.request.id, null);
    if (!mounted) return;
    setState(() => _busy = false);
    _showResult(result, approved: false);
  }

  void _showResult(ApprovalSubmissionResult result, {required bool approved}) {
    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case ApprovalSubmissionResult.ok:
        messenger.showSnackBar(SnackBar(
          content: Text(approved ? 'Approved' : 'Rejected'),
        ));
        Navigator.of(context).maybePop();
      case ApprovalSubmissionResult.refusedOffline:
        messenger.showSnackBar(const SnackBar(
          content: Text(
            'Floor-relevant actions require a network connection. '
            'Reconnect and try again — the request is unchanged.',
          ),
        ));
      case ApprovalSubmissionResult.serverError:
        messenger.showSnackBar(const SnackBar(
          content: Text('Submission failed. Try again.'),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _toolHeader(r),
          const SizedBox(height: 16),
          _ArtifactView(artifact: r.artifact),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _reject,
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _approve,
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toolHeader(ApprovalRequestView r) {
    return Row(
      children: [
        const Icon(Icons.outbox, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.toolName,
                  style: Theme.of(context).textTheme.titleLarge),
              Text(r.toolGlobalUri,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArtifactView extends StatelessWidget {
  const _ArtifactView({required this.artifact});

  final Artifact artifact;

  @override
  Widget build(BuildContext context) {
    switch (artifact.kind) {
      case ArtifactKind.email:
        return _EmailArtifact(artifact: artifact);
      case ArtifactKind.generic:
        return _GenericArtifact(artifact: artifact);
    }
  }
}

class _EmailArtifact extends StatelessWidget {
  const _EmailArtifact({required this.artifact});

  final Artifact artifact;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kv(context, 'To', artifact.recipient ?? '(unknown)'),
            const SizedBox(height: 8),
            _kv(context, 'Subject', artifact.subject),
            const Divider(),
            Text(artifact.body),
          ],
        ),
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(k,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
        ),
        Expanded(child: Text(v)),
      ],
    );
  }
}

class _GenericArtifact extends StatelessWidget {
  const _GenericArtifact({required this.artifact});

  final Artifact artifact;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (artifact.recipient != null)
              Text('Recipient: ${artifact.recipient}'),
            const SizedBox(height: 8),
            Text(artifact.content.toString()),
          ],
        ),
      ),
    );
  }
}
