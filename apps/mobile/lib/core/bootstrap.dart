import 'package:ferry/ferry.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'graphql/client.dart';
import 'graphql/ferry_helpers.dart';

import '../graphql/__generated__/schema.schema.gql.dart';
import '../graphql/operations/__generated__/pair_device.req.gql.dart';
import '../graphql/operations/__generated__/inbox.req.gql.dart';
import '../graphql/operations/__generated__/inbox.data.gql.dart';
import '../graphql/operations/__generated__/agent_assignment.req.gql.dart';
import '../graphql/operations/__generated__/complete_task.req.gql.dart';
import '../graphql/operations/__generated__/create_task.req.gql.dart';
import '../graphql/operations/__generated__/task_changed_subscription.req.gql.dart';
import '../graphql/operations/__generated__/approval.req.gql.dart';
import '../graphql/operations/__generated__/approval.data.gql.dart';
import '../graphql/operations/__generated__/feedback.req.gql.dart';
import '../graphql/operations/__generated__/feedback.data.gql.dart';
import '../graphql/operations/__generated__/routing.req.gql.dart';
import '../graphql/operations/__generated__/tasks.req.gql.dart';
import '../graphql/operations/__generated__/tasks.data.gql.dart';
import '../graphql/operations/__generated__/task_detail.req.gql.dart';
import '../graphql/operations/__generated__/task_detail.data.gql.dart';

import '../features/pairing/pairing_page.dart';
import '../features/inbox/inbox_page.dart';
import '../features/task/assignment_view.dart';
import '../features/task/task_provider.dart';
import '../features/task/create_task_provider.dart';
import '../features/approval/approval_provider.dart';
import '../features/approval/approval_models.dart';
import '../features/feedback/feedback_provider.dart';
import '../features/feedback/feedback_models.dart';
import '../features/routing/routing_provider.dart';
import '../features/routing/routing_models.dart';
import '../features/tasks/tasks_provider.dart';
import '../features/tasks/tasks_models.dart';

/// ferryOverrides wires every stubbed provider to a real Ferry operation
/// against [ferryClientProvider]. This is the "bootstrap layer" the feature
/// providers document: without it the app's providers throw
/// `UnimplementedError` / emit nothing. Applied in `main.dart`'s ProviderScope.
List<Override> ferryOverrides() => [
      // ---- Pairing -----------------------------------------------------
      pairDeviceProvider.overrideWith((ref) async {
        final client = ref.watch(ferryClientProvider);
        return ({required String secret, required String displayName}) async {
          final data = await runOnceRequired(
            client,
            GPairDeviceReq((b) => b
              ..vars.password = secret
              ..vars.displayName = displayName),
          );
          return data.pairDevice.token;
        };
      }),

      // ---- Inbox (one-shot query) -------------------------------------
      inboxItemsProvider.overrideWith((ref) async {
        final client = ref.watch(ferryClientProvider);
        final data = await runOnceRequired(
          client,
          GInboxReq((b) => b
            ..vars.first = 50
            ..fetchPolicy = FetchPolicy.NetworkOnly),
        );
        return _mapInbox(data);
      }),

      // ---- Assignment detail + complete -------------------------------
      assignmentProvider.overrideWith((ref, id) async {
        final client = ref.watch(ferryClientProvider);
        final data = await runOnce(
          client,
          GAgentAssignmentReq((b) => b
            ..vars.id = id
            ..fetchPolicy = FetchPolicy.NetworkOnly),
        );
        final a = data?.agentAssignment;
        if (a == null) return null;
        return AssignmentDetail(id: a.id, taskId: a.task.id, ask: a.ask);
      }),
      completeTaskProvider.overrideWith((ref) async {
        final client = ref.watch(ferryClientProvider);
        return (String taskId) async {
          await runOnceRequired(
            client,
            GCompleteTaskReq((b) => b..vars.taskId = taskId),
          );
        };
      }),

      // ---- Create task (manual compose) -------------------------------
      createTaskProvider.overrideWith((ref) async {
        final client = ref.watch(ferryClientProvider);
        return ({required String title, String? description}) async {
          await runOnceRequired(
            client,
            GCreateTaskReq((b) => b
              ..vars.title = title
              ..vars.description =
                  (description != null && description.isEmpty)
                      ? null
                      : description),
          );
        };
      }),

      // ---- Task change subscription -----------------------------------
      taskChangedProvider.overrideWith((ref, taskId) {
        final client = ref.watch(ferryClientProvider);
        return client
            .request(GTaskChangedReq((b) => b..vars.taskId = taskId))
            .handleError((_) {}) // swallow transient transport drops
            .where((r) => r.data != null)
            .map<dynamic>((r) => r.data);
      }),

      // ---- Tasks list (one-shot query, filterable) --------------------
      tasksListProvider.overrideWith((ref, filter) async {
        final client = ref.watch(ferryClientProvider);
        final data = await runOnceRequired(
          client,
          GTasksReq((b) {
            b
              ..vars.first = 50
              ..fetchPolicy = FetchPolicy.NetworkOnly;
            final st = _serverState(filter);
            if (st != null) b.vars.state = st;
          }),
        );
        return _mapTasks(data, filter);
      }),

      // ---- All-tasks live subscription (drives list refresh) ----------
      allTasksChangedProvider.overrideWith((ref) {
        final client = ref.watch(ferryClientProvider);
        return client
            .request(GTaskChangedReq((b) => b..vars.taskId = null))
            .handleError((_) {}) // swallow transient transport drops
            .where((r) => r.data != null)
            .map<void>((_) {});
      }),

      // ---- Task detail (header + stage slots + findings + activity) ----
      taskDetailProvider.overrideWith((ref, id) async {
        final client = ref.watch(ferryClientProvider);
        final data = await runOnce(
          client,
          GTaskDetailReq((b) => b
            ..vars.id = id
            ..fetchPolicy = FetchPolicy.NetworkOnly),
        );
        final t = data?.task;
        if (t == null) return null;
        return _mapTaskDetail(t);
      }),

      // ---- Approval detail + mutator ----------------------------------
      approvalRequestProvider.overrideWith((ref, id) async {
        final client = ref.watch(ferryClientProvider);
        final data = await runOnce(
          client,
          GPendingDecisionReq((b) => b
            ..vars.id = id
            ..fetchPolicy = FetchPolicy.NetworkOnly),
        );
        return _mapApproval(data?.pendingDecision);
      }),
      approvalMutatorProvider.overrideWith((ref) {
        final client = ref.watch(ferryClientProvider);
        return FloorAwareApprovalMutator(
          inner: _FerryApprovalMutator(client),
          isOnline: () => ref.read(onlineProvider),
        );
      }),

      // ---- Feedback conversation + mutator ----------------------------
      feedbackConversationProvider.overrideWith((ref, id) async {
        final client = ref.watch(ferryClientProvider);
        final data = await runOnce(
          client,
          GFeedbackRequestReq((b) => b
            ..vars.id = id
            ..fetchPolicy = FetchPolicy.NetworkOnly),
        );
        return _mapFeedbackConvo(data?.pendingDecision);
      }),
      feedbackMutatorProvider.overrideWith((ref) {
        final client = ref.watch(ferryClientProvider);
        return _FerryFeedbackMutator(client);
      }),

      // ---- Routing (Phase 6) ------------------------------------------
      taskStageSlotsProvider.overrideWith((ref, taskId) async {
        final client = ref.watch(ferryClientProvider);
        final data = await runOnce(
          client,
          GTaskStageSlotsReq((b) => b
            ..vars.taskId = taskId
            ..fetchPolicy = FetchPolicy.NetworkOnly),
        );
        final task = data?.task;
        if (task == null) return <StageSlotView>[];
        return [
          for (final s in task.stageSlots)
            StageSlotView(
              stage: _stageView(s.stage),
              isHuman: s.isHuman,
              occupant: s.occupant == null
                  ? null
                  : AgentConfigView(
                      id: s.occupant!.id,
                      name: s.occupant!.name,
                      stage: _stageView(s.occupant!.stage),
                      isHuman: s.occupant!.isHuman,
                      model: s.occupant!.model,
                      origin: s.occupant!.origin,
                      version: s.occupant!.version,
                    ),
            ),
        ];
      }),
      agentConfigsProvider.overrideWith((ref, stage) async {
        final client = ref.watch(ferryClientProvider);
        final data = await runOnce(
          client,
          GAgentConfigsReq((b) {
            b.fetchPolicy = FetchPolicy.NetworkOnly;
            if (stage != null) b.vars.stage = _gStage(stage);
          }),
        );
        final list = data?.agentConfigs;
        if (list == null) return <AgentConfigView>[];
        return [
          for (final c in list)
            AgentConfigView(
              id: c.id,
              name: c.name,
              stage: _stageView(c.stage),
              isHuman: c.isHuman,
              model: c.model,
              origin: c.origin,
              version: c.version,
            ),
        ];
      }),
    ];

// ---------------------------------------------------------------------------
// Mapping helpers
// ---------------------------------------------------------------------------

List<InboxItemRef> _mapInbox(GInboxData data) {
  final out = <InboxItemRef>[];
  for (final node in data.inbox) {
    switch (node.G__typename) {
      case 'AgentAssignment':
        final a = node as GInboxData_inbox__asAgentAssignment;
        out.add(InboxItemRef(
          id: a.id,
          typename: 'AgentAssignment',
          title: a.task.title,
          subtitle: a.ask,
        ));
        break;
      case 'ApprovalRequest':
        final r = node as GInboxData_inbox__asApprovalRequest;
        out.add(InboxItemRef(
          id: r.id,
          typename: 'ApprovalRequest',
          title: 'Approval requested',
          subtitle: 'Tap to review',
        ));
        break;
      case 'AgentQuestion':
        final q = node as GInboxData_inbox__asAgentQuestion;
        out.add(InboxItemRef(
          id: q.id,
          typename: 'AgentQuestion',
          title: 'Question',
          subtitle: q.question,
        ));
        break;
      case 'PromotionProposal':
        final p = node as GInboxData_inbox__asPromotionProposal;
        out.add(InboxItemRef(
          id: p.id,
          typename: 'PromotionProposal',
          title: 'Promotion proposal',
          subtitle: '${p.fromLevel.name} → ${p.toLevel.name}',
        ));
        break;
      case 'FeedbackRequest':
        final f = node as GInboxData_inbox__asFeedbackRequest;
        out.add(InboxItemRef(
          id: f.id,
          typename: 'FeedbackRequest',
          title: 'Feedback: ${f.task.title}',
          subtitle: 'How did this task go? Tap to chat.',
        ));
        break;
    }
  }
  return out;
}

List<TaskRef> _mapTasks(GTasksData data, TasksFilter filter) {
  final out = <TaskRef>[];
  for (final edge in data.tasks.edges) {
    final n = edge.node;
    final slots = [
      for (final s in n.stageSlots)
        TaskStageOccupancy(
          stage: _stageView(s.stage),
          isHuman: s.isHuman,
          occupantName: s.occupant?.name,
          occupantModel: s.occupant?.model,
        ),
    ];
    final task = TaskRef(
      id: n.id,
      title: n.title,
      state: n.state.name,
      currentStage: n.currentStage.name,
      autonomy: n.autonomy.name,
      hasOpenAssignment: n.openAssignment != null,
      stageSlots: slots,
    );
    // The server `state` arg is single-valued, so "Active" (any in-flight
    // state) is enforced client-side.
    if (filter == TasksFilter.active && task.isTerminal) continue;
    out.add(task);
  }
  return out;
}

Map<String, dynamic> _asMap(Object? jsonValue) {
  final v = jsonValue;
  return v is Map ? v.cast<String, dynamic>() : <String, dynamic>{};
}

TaskDetail _mapTaskDetail(GTaskDetailData_task t) {
  return TaskDetail(
    id: t.id,
    title: t.title,
    description: t.description,
    state: t.state.name,
    currentStage: t.currentStage.name,
    autonomy: t.autonomy.name,
    findings: _asMap(t.findings?.value),
    stageSlots: [
      for (final s in t.stageSlots)
        TaskStageOccupancy(
          stage: _stageView(s.stage),
          isHuman: s.isHuman,
          occupantName: s.occupant?.name,
          occupantModel: s.occupant?.model,
        ),
    ],
    activity: [
      for (final e in t.activity)
        ActivityEventRef(
          id: e.id,
          kind: e.kind,
          at: e.at.value,
          actor: e.actor,
          inReplyTo: e.inReplyTo,
          detail: _asMap(e.detail?.value),
        ),
    ],
  );
}

GTaskState? _serverState(TasksFilter f) {
  switch (f) {
    case TasksFilter.active:
    case TasksFilter.all:
      return null;
    case TasksFilter.proposed:
      return GTaskState.PROPOSED;
    case TasksFilter.accepted:
      return GTaskState.ACCEPTED;
    case TasksFilter.waiting:
      return GTaskState.WAITING;
    case TasksFilter.executing:
      return GTaskState.EXECUTING;
    case TasksFilter.done:
      return GTaskState.DONE;
    case TasksFilter.dismissed:
      return GTaskState.DISMISSED;
    case TasksFilter.halted:
      return GTaskState.HALTED;
  }
}

ApprovalRequestView? _mapApproval(
  GPendingDecisionData_pendingDecision? d,
) {
  if (d == null || d.G__typename != 'ApprovalRequest') return null;
  final ar = d as GPendingDecisionData_pendingDecision__asApprovalRequest;

  Artifact artifact;
  final payload = ar.payload;
  if (payload.G__typename == 'Artifact') {
    final art = payload
        as GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact;
    final raw = art.content.value;
    artifact = Artifact(
      kind: artifactKindFromString(art.kind),
      content: raw is Map ? raw.cast<String, dynamic>() : <String, dynamic>{},
      recipient: art.recipient,
    );
  } else {
    artifact = const Artifact(kind: ArtifactKind.generic, content: {});
  }

  OverseerEvaluationView? oe;
  final o = ar.overseerEvaluation;
  if (o != null) {
    oe = OverseerEvaluationView(
      verdict: o.verdict,
      summary: o.summary,
      consideredFields: o.consideredFields.toList(),
      modelId: o.modelId,
      provider: o.provider,
      tokensIn: o.tokensIn,
      tokensOut: o.tokensOut,
      estimatedCostUsd: o.estimatedCostUsd,
    );
  }

  return ApprovalRequestView(
    id: ar.id,
    toolName: ar.tool.name,
    toolGlobalUri: ar.tool.globalUri,
    artifact: artifact,
    overseerEvaluation: oe,
  );
}

AgentStageView _stageView(GAgentStage s) {
  if (s == GAgentStage.TRIAGE) return AgentStageView.triage;
  if (s == GAgentStage.EXPANSION) return AgentStageView.expansion;
  return AgentStageView.execution;
}

GAgentStage _gStage(AgentStageView v) {
  switch (v) {
    case AgentStageView.triage:
      return GAgentStage.TRIAGE;
    case AgentStageView.expansion:
      return GAgentStage.EXPANSION;
    case AgentStageView.execution:
      return GAgentStage.EXECUTION;
  }
}

/// _FerryApprovalMutator runs the approve/reject mutations. Wrapped by
/// [FloorAwareApprovalMutator] (the offline floor rail) in the override above.
class _FerryApprovalMutator implements ApprovalMutator {
  _FerryApprovalMutator(this._client);

  final Client _client;

  @override
  Future<ApprovalSubmissionResult> approve(String decisionId) async {
    try {
      await runOnceRequired(
        _client,
        GApproveArtifactReq((b) => b..vars.decisionId = decisionId),
      );
      return ApprovalSubmissionResult.ok;
    } catch (_) {
      return ApprovalSubmissionResult.serverError;
    }
  }

  @override
  Future<ApprovalSubmissionResult> reject(
      String decisionId, String? reason) async {
    try {
      await runOnceRequired(
        _client,
        GRejectApprovalReq((b) => b
          ..vars.decisionId = decisionId
          ..vars.reason = reason),
      );
      return ApprovalSubmissionResult.ok;
    } catch (_) {
      return ApprovalSubmissionResult.serverError;
    }
  }
}

// ---------------------------------------------------------------------------
// Feedback mapping + mutator
// ---------------------------------------------------------------------------

FeedbackConversationView? _mapFeedbackConvo(
  GFeedbackRequestData_pendingDecision? d,
) {
  if (d == null || d.G__typename != 'FeedbackRequest') return null;
  final f = d as GFeedbackRequestData_pendingDecision__asFeedbackRequest;
  return FeedbackConversationView(
    id: f.id,
    taskTitle: f.task.title,
    draftGuidance: f.draftGuidance,
    messages: [
      for (final m in f.messages)
        FeedbackMessageView(
          id: m.id,
          role: feedbackRoleFromString(m.role),
          content: m.content,
        ),
    ],
  );
}

GGuidanceScope _gScope(GuidanceScopeView s) =>
    s == GuidanceScopeView.agent ? GGuidanceScope.AGENT : GGuidanceScope.GLOBAL;

/// _FerryFeedbackMutator drives the feedback conversation + accept/dismiss.
class _FerryFeedbackMutator implements FeedbackMutator {
  _FerryFeedbackMutator(this._client);

  final Client _client;

  @override
  Future<FeedbackConversationView?> send(String decisionId, String text) async {
    try {
      final data = await runOnceRequired(
        _client,
        GSendFeedbackMessageReq((b) => b
          ..vars.decisionId = decisionId
          ..vars.text = text),
      );
      final s = data.sendFeedbackMessage;
      return FeedbackConversationView(
        id: s.id,
        taskTitle: '',
        draftGuidance: s.draftGuidance,
        messages: [
          for (final m in s.messages)
            FeedbackMessageView(
              id: m.id,
              role: feedbackRoleFromString(m.role),
              content: m.content,
            ),
        ],
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<FeedbackSubmitResult> accept(
    String decisionId,
    String guidance,
    GuidanceScopeView scope,
    String? agentConfigId,
    int? rating,
  ) async {
    try {
      await runOnceRequired(
        _client,
        GAcceptFeedbackGuidanceReq((b) {
          b
            ..vars.decisionId = decisionId
            ..vars.guidance = guidance
            ..vars.scope = _gScope(scope);
          if (agentConfigId != null) b.vars.agentConfigId = agentConfigId;
          if (rating != null) b.vars.rating = rating;
        }),
      );
      return FeedbackSubmitResult.ok;
    } catch (_) {
      return FeedbackSubmitResult.serverError;
    }
  }

  @override
  Future<FeedbackSubmitResult> dismiss(String decisionId, int? rating) async {
    try {
      await runOnceRequired(
        _client,
        GDismissFeedbackReq((b) {
          b.vars.decisionId = decisionId;
          if (rating != null) b.vars.rating = rating;
        }),
      );
      return FeedbackSubmitResult.ok;
    } catch (_) {
      return FeedbackSubmitResult.serverError;
    }
  }
}
