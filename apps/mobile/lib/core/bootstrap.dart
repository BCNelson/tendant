import 'package:ferry/ferry.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'graphql/client.dart';
import 'graphql/ferry_helpers.dart';

import '../graphql/__generated__/schema.schema.gql.dart';
import '../graphql/operations/__generated__/pair_device.req.gql.dart';
import '../graphql/operations/__generated__/inbox.req.gql.dart';
import '../graphql/operations/__generated__/inbox.data.gql.dart';
import '../graphql/operations/__generated__/inbox_subscription.req.gql.dart';
import '../graphql/operations/__generated__/inbox_state.req.gql.dart';
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
import '../graphql/operations/__generated__/update_task_metadata.req.gql.dart';
import '../graphql/operations/__generated__/proposed_task.req.gql.dart';

import '../features/pairing/pairing_page.dart';
import '../features/inbox/inbox_provider.dart';
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

      // ---- Inbox ranked feed (paginated page fetcher) -----------------
      inboxFeedFetcherProvider.overrideWith((ref) {
        final client = ref.watch(ferryClientProvider);
        return (String? after) async {
          final data = await runOnceRequired(
            client,
            GInboxFeedReq((b) {
              b.vars.first = 25;
              if (after != null) b.vars.after = after;
            }),
          );
          return _mapInboxFeed(data);
        };
      }),

      // ---- Inbox inline accept/dismiss (ActionableTask cards) ---------
      proposedTaskMutatorProvider.overrideWith((ref) {
        final client = ref.watch(ferryClientProvider);
        return _FerryProposedTaskMutator(client);
      }),
      inboxStateMutatorProvider.overrideWith((ref) {
        final client = ref.watch(ferryClientProvider);
        return _FerryInboxStateMutator(client);
      }),

      // ---- Inbox live arrival subscription (drives feed refresh) ------
      inboxArrivedProvider.overrideWith((ref) {
        final client = ref.watch(ferryClientProvider);
        return _resilientTicks(() => client.request(GInboxEntryArrivedReq()));
      }),

      // ---- Assignment detail + complete -------------------------------
      assignmentProvider.overrideWith((ref, id) async {
        final client = ref.watch(ferryClientProvider);
        final data = await runOnce(
          client,
          GAgentAssignmentReq((b) => b..vars.id = id),
        );
        final a = data?.agentAssignment;
        if (a == null) return null;
        return AssignmentDetail(
            id: a.id,
            taskId: a.task.id,
            taskShortId: a.task.shortId,
            ask: a.ask);
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
        return ({
          required String title,
          String? description,
          String? priority,
          DateTime? dueAt,
        }) async {
          await runOnceRequired(
            client,
            GCreateTaskReq((b) => b
              ..vars.title = title
              ..vars.description =
                  (description != null && description.isEmpty)
                      ? null
                      : description
              // null priority → omit the var so the server applies NORMAL.
              ..vars.priority =
                  (priority == null) ? null : GTaskPriority.valueOf(priority)
              // dueAt is sent as a UTC ISO-8601 Time scalar; null → no deadline.
              ..vars.dueAt = (dueAt == null)
                  ? null
                  : GTime(dueAt.toUtc().toIso8601String()).toBuilder()),
          );
        };
      }),

      // ---- Task change subscription -----------------------------------
      taskChangedProvider.overrideWith((ref, taskId) {
        final client = ref.watch(ferryClientProvider);
        return _resilientTicks(
            () => client.request(GTaskChangedReq((b) => b..vars.taskId = taskId)));
      }),

      // ---- Tasks list (one-shot query, keyed by server state) ----------
      // Keyed by the server `TaskState` name (null = unfiltered), so the
      // "Active" and "All" UI filters — both unfiltered — share this one fetch.
      rawTasksProvider.overrideWith((ref, serverState) {
        final client = ref.watch(ferryClientProvider);
        // Watch the request against the normalized cache: emits cached rows
        // instantly, then the network result, then re-emits on any cache merge
        // touching a referenced Task (e.g. a `taskChanged` subscription push).
        return client
            .request(GTasksReq((b) {
              b.vars.first = 50;
              if (serverState != null) {
                b.vars.state = GTaskState.valueOf(serverState);
              }
            }))
            .where((r) => r.data != null)
            .map((r) => _mapTasks(r.data!));
      }),

      // ---- All-tasks live subscription (drives list refresh) ----------
      allTasksChangedProvider.overrideWith((ref) {
        final client = ref.watch(ferryClientProvider);
        return _resilientTicks(
            () => client.request(GTaskChangedReq((b) => b..vars.taskId = null)));
      }),

      // ---- Task detail (header + stage slots + findings + activity) ----
      taskDetailProvider.overrideWith((ref, id) {
        final client = ref.watch(ferryClientProvider);
        // Cache-watched: header + stage-slot fields re-emit on a `taskChanged`
        // merge; the signal-driven invalidate in the detail view refreshes the
        // activity timeline (a list, not a single entity).
        return client
            .request(GTaskDetailReq((b) => b..vars.id = id))
            .where((r) => r.data != null)
            .map((r) {
              final t = r.data!.task;
              return t == null ? null : _mapTaskDetail(t);
            });
      }),

      // ---- Edit task metadata (priority + due date) -------------------
      updateTaskMetadataProvider.overrideWith((ref) async {
        final client = ref.watch(ferryClientProvider);
        return (String taskId,
            {required String priority, DateTime? dueAt}) async {
          await runOnceRequired(
            client,
            GUpdateTaskMetadataReq((b) => b
              ..vars.taskId = taskId
              ..vars.priority = GTaskPriority.valueOf(priority)
              ..vars.dueAt = (dueAt == null)
                  ? null
                  : GTime(dueAt.toUtc().toIso8601String()).toBuilder()),
          );
        };
      }),

      // ---- Approval detail + mutator ----------------------------------
      approvalRequestProvider.overrideWith((ref, id) async {
        final client = ref.watch(ferryClientProvider);
        final data = await runOnce(
          client,
          GPendingDecisionReq((b) => b..vars.id = id),
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
          GFeedbackRequestReq((b) => b..vars.id = id),
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
          GTaskStageSlotsReq((b) => b..vars.taskId = taskId),
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

/// _resilientTicks turns a Ferry subscription request into a self-healing
/// stream of distinct ticks. It resubscribes (after a short delay) if the
/// underlying stream errors or completes, so a fatal websocket error can't
/// leave the live channel permanently dead — the previous `.handleError((_){})`
/// swallowed the error and the subscription stayed dead until a manual page
/// refresh. The transport's own (now effectively-infinite) reconnect handles
/// the common case; this is the backstop for fatal closes. Each data event
/// yields a distinct counter so Riverpod's repeat-equal `AsyncData` suppression
/// can't drop a refresh.
Stream<int> _resilientTicks<TData, TVars>(
  Stream<OperationResponse<TData, TVars>> Function() open,
) async* {
  var tick = 0;
  while (true) {
    try {
      await for (final r in open()) {
        if (r.data != null) yield ++tick;
      }
    } catch (_) {
      // fall through and resubscribe
    }
    await Future<void>.delayed(const Duration(seconds: 3));
  }
}

// ---------------------------------------------------------------------------
// Mapping helpers
// ---------------------------------------------------------------------------

InboxFeedResult _mapInboxFeed(GInboxFeedData data) {
  final out = <InboxEntryRef>[];
  for (final e in data.inboxFeed.entries) {
    final item = e.item;
    switch (item.G__typename) {
      case 'ActionableTask':
        final a =
            item as GInboxFeedData_inboxFeed_entries_item__asActionableTask;
        out.add(InboxEntryRef(
          entryId: e.id,
          kind: e.kind,
          urgency: e.urgency,
          messageType: e.messageType,
          unread: e.readAt == null,
          itemId: a.id,
          title: a.task.title,
          subtitle: 'Proposed',
          taskId: a.task.id,
          taskShortId: a.task.shortId,
          priority: a.task.priority.name,
          dueAt: a.task.dueAt == null
              ? null
              : DateTime.tryParse(a.task.dueAt!.value)?.toLocal(),
          taskState: a.task.state.name,
        ));
        break;
      case 'AgentAssignment':
        final asn =
            item as GInboxFeedData_inboxFeed_entries_item__asAgentAssignment;
        out.add(InboxEntryRef(
          entryId: e.id,
          kind: e.kind,
          urgency: e.urgency,
          messageType: e.messageType,
          unread: e.readAt == null,
          itemId: asn.id,
          title: asn.task.title,
          subtitle: asn.ask,
          taskShortId: asn.task.shortId,
        ));
        break;
      case 'ApprovalRequest':
        final r =
            item as GInboxFeedData_inboxFeed_entries_item__asApprovalRequest;
        out.add(InboxEntryRef(
          entryId: e.id,
          kind: e.kind,
          urgency: e.urgency,
          messageType: e.messageType,
          unread: e.readAt == null,
          itemId: r.id,
          title: 'Approval requested',
          subtitle: 'Tap to review',
        ));
        break;
      case 'AgentQuestion':
        final q =
            item as GInboxFeedData_inboxFeed_entries_item__asAgentQuestion;
        out.add(InboxEntryRef(
          entryId: e.id,
          kind: e.kind,
          urgency: e.urgency,
          messageType: e.messageType,
          unread: e.readAt == null,
          itemId: q.id,
          title: 'Question',
          subtitle: q.question,
        ));
        break;
      case 'PromotionProposal':
        final p =
            item as GInboxFeedData_inboxFeed_entries_item__asPromotionProposal;
        out.add(InboxEntryRef(
          entryId: e.id,
          kind: e.kind,
          urgency: e.urgency,
          messageType: e.messageType,
          unread: e.readAt == null,
          itemId: p.id,
          title: 'Promotion proposal',
          subtitle: '${p.fromLevel.name} → ${p.toLevel.name}',
        ));
        break;
      case 'FeedbackRequest':
        final f =
            item as GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest;
        out.add(InboxEntryRef(
          entryId: e.id,
          kind: e.kind,
          urgency: e.urgency,
          messageType: e.messageType,
          unread: e.readAt == null,
          itemId: f.id,
          title: 'Feedback: ${f.task.title}',
          subtitle: 'How did this task go? Tap to chat.',
          taskShortId: f.task.shortId,
        ));
        break;
    }
  }
  return InboxFeedResult(entries: out, nextCursor: data.inboxFeed.nextCursor);
}

/// _FerryProposedTaskMutator runs the inbox inline accept/dismiss mutations on
/// PROPOSED tasks (ActionableTask cards). Both are `lowStakes` per the floor
/// rail.
class _FerryProposedTaskMutator implements ProposedTaskMutator {
  _FerryProposedTaskMutator(this._client);

  final Client _client;

  @override
  Future<bool> accept(String taskId) async {
    try {
      await runOnceRequired(
        _client,
        GAcceptProposedTaskReq((b) => b..vars.taskId = taskId),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> dismiss(String taskId, {String? reason}) async {
    try {
      await runOnceRequired(
        _client,
        GDismissProposedTaskReq((b) {
          b.vars.taskId = taskId;
          if (reason != null) b.vars.reason = reason;
        }),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// _FerryInboxStateMutator runs the per-message read/dismiss mutations against
/// the first-class inbox_messages row. markRead is fire-and-forget (best-effort
/// — a failed read stamp is harmless); dismiss reports success so the UI can
/// roll back an optimistic removal.
class _FerryInboxStateMutator implements InboxStateMutator {
  _FerryInboxStateMutator(this._client);

  final Client _client;

  @override
  Future<void> markRead(String messageId) async {
    try {
      await runOnceRequired(
        _client,
        GMarkInboxReadReq((b) => b..vars.id = messageId),
      );
    } catch (_) {
      // Best-effort: an unsent read stamp simply leaves the dot showing.
    }
  }

  @override
  Future<bool> dismiss(String messageId) async {
    try {
      await runOnceRequired(
        _client,
        GDismissInboxMessageReq((b) => b..vars.id = messageId),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

List<TaskRef> _mapTasks(GTasksData data) {
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
    out.add(TaskRef(
      id: n.id,
      shortId: n.shortId,
      title: n.title,
      state: n.state.name,
      currentStage: n.currentStage.name,
      autonomy: n.autonomy.name,
      hasOpenAssignment: n.openAssignment != null,
      stageSlots: slots,
    ));
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
    shortId: t.shortId,
    title: t.title,
    description: t.description,
    state: t.state.name,
    currentStage: t.currentStage.name,
    autonomy: t.autonomy.name,
    priority: t.priority.name,
    dueAt: t.dueAt == null ? null : DateTime.tryParse(t.dueAt!.value)?.toLocal(),
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
  final c = f.context;
  return FeedbackConversationView(
    id: f.id,
    taskTitle: f.task.title,
    taskShortId: f.task.shortId,
    draftGuidance: f.draftGuidance,
    messages: [
      for (final m in f.messages)
        FeedbackMessageView(
          id: m.id,
          role: feedbackRoleFromString(m.role),
          content: m.content,
        ),
    ],
    context: c == null
        ? null
        : FeedbackContextView(
            toolsRun: c.toolsRun,
            toolsFlagged: c.toolsFlagged,
            agentStages: c.agentStages.toList(growable: false),
            activeGuidanceCount: c.activeGuidanceCount,
            consulted: c.consulted.toList(growable: false),
            summary: c.summary,
            handoffReason: c.handoffReason,
          ),
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
