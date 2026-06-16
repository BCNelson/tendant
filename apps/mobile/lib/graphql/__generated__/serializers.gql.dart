// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart' show StandardJsonPlugin;
import 'package:ferry_exec/ferry_exec.dart';
import 'package:gql_code_builder_serializers/gql_code_builder_serializers.dart'
    show OperationSerializer;
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart'
    show
        GAgentStage,
        GAutonomyLevel,
        GBytes,
        GChainStage,
        GDevicePlatform,
        GGateScriptStatus,
        GGateScriptTier,
        GGuidanceScope,
        GSetTaskCategoryInput,
        GTaskPriority,
        GTaskRelationKind,
        GTaskState,
        GTime;
import 'package:tendant/graphql/operations/__generated__/agent_assignment.data.gql.dart'
    show
        GAgentAssignmentData,
        GAgentAssignmentData_agentAssignment,
        GAgentAssignmentData_agentAssignment_task;
import 'package:tendant/graphql/operations/__generated__/agent_assignment.req.gql.dart'
    show GAgentAssignmentReq;
import 'package:tendant/graphql/operations/__generated__/agent_assignment.var.gql.dart'
    show GAgentAssignmentVars;
import 'package:tendant/graphql/operations/__generated__/approval.data.gql.dart'
    show
        GPendingDecisionData_pendingDecision,
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload,
        GAnswerQuestionData,
        GAnswerQuestionData_answerQuestion,
        GApproveArtifactData,
        GApproveArtifactData_approveArtifact,
        GPendingDecisionData,
        GPendingDecisionData_pendingDecision__asAgentQuestion,
        GPendingDecisionData_pendingDecision__asAgentQuestion_asker,
        GPendingDecisionData_pendingDecision__asApprovalRequest,
        GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation,
        GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation,
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact,
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate,
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base,
        GPendingDecisionData_pendingDecision__asApprovalRequest_tool,
        GPendingDecisionData_pendingDecision__base,
        GRejectApprovalData,
        GRejectApprovalData_rejectApproval;
import 'package:tendant/graphql/operations/__generated__/approval.req.gql.dart'
    show
        GAnswerQuestionReq,
        GApproveArtifactReq,
        GPendingDecisionReq,
        GRejectApprovalReq;
import 'package:tendant/graphql/operations/__generated__/approval.var.gql.dart'
    show
        GAnswerQuestionVars,
        GApproveArtifactVars,
        GPendingDecisionVars,
        GRejectApprovalVars;
import 'package:tendant/graphql/operations/__generated__/complete_task.data.gql.dart'
    show GCompleteTaskData, GCompleteTaskData_completeTask;
import 'package:tendant/graphql/operations/__generated__/complete_task.req.gql.dart'
    show GCompleteTaskReq;
import 'package:tendant/graphql/operations/__generated__/complete_task.var.gql.dart'
    show GCompleteTaskVars;
import 'package:tendant/graphql/operations/__generated__/create_task.data.gql.dart'
    show GCreateTaskData, GCreateTaskData_createTask;
import 'package:tendant/graphql/operations/__generated__/create_task.req.gql.dart'
    show GCreateTaskReq;
import 'package:tendant/graphql/operations/__generated__/create_task.var.gql.dart'
    show GCreateTaskVars;
import 'package:tendant/graphql/operations/__generated__/feedback.data.gql.dart'
    show
        GFeedbackRequestData_pendingDecision,
        GAcceptFeedbackGuidanceData,
        GAcceptFeedbackGuidanceData_acceptFeedbackGuidance,
        GDismissFeedbackData,
        GDismissFeedbackData_dismissFeedback,
        GFeedbackRequestData,
        GFeedbackRequestData_pendingDecision__asFeedbackRequest,
        GFeedbackRequestData_pendingDecision__asFeedbackRequest_context,
        GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages,
        GFeedbackRequestData_pendingDecision__asFeedbackRequest_task,
        GFeedbackRequestData_pendingDecision__base,
        GSendFeedbackMessageData,
        GSendFeedbackMessageData_sendFeedbackMessage,
        GSendFeedbackMessageData_sendFeedbackMessage_messages;
import 'package:tendant/graphql/operations/__generated__/feedback.req.gql.dart'
    show
        GAcceptFeedbackGuidanceReq,
        GDismissFeedbackReq,
        GFeedbackRequestReq,
        GSendFeedbackMessageReq;
import 'package:tendant/graphql/operations/__generated__/feedback.var.gql.dart'
    show
        GAcceptFeedbackGuidanceVars,
        GDismissFeedbackVars,
        GFeedbackRequestVars,
        GSendFeedbackMessageVars;
import 'package:tendant/graphql/operations/__generated__/inbox.data.gql.dart'
    show
        GInboxFeedData_inboxFeed_entries_item,
        GInboxFeedData,
        GInboxFeedData_inboxFeed,
        GInboxFeedData_inboxFeed_entries,
        GInboxFeedData_inboxFeed_entries_item__asActionableTask,
        GInboxFeedData_inboxFeed_entries_item__asActionableTask_task,
        GInboxFeedData_inboxFeed_entries_item__asAgentAssignment,
        GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task,
        GInboxFeedData_inboxFeed_entries_item__asAgentQuestion,
        GInboxFeedData_inboxFeed_entries_item__asApprovalRequest,
        GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest,
        GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task,
        GInboxFeedData_inboxFeed_entries_item__asPromotionProposal,
        GInboxFeedData_inboxFeed_entries_item__base;
import 'package:tendant/graphql/operations/__generated__/inbox.req.gql.dart'
    show GInboxFeedReq;
import 'package:tendant/graphql/operations/__generated__/inbox.var.gql.dart'
    show GInboxFeedVars;
import 'package:tendant/graphql/operations/__generated__/inbox_state.data.gql.dart'
    show
        GDismissInboxMessageData,
        GDismissInboxMessageData_dismissInboxMessage,
        GMarkInboxReadData,
        GMarkInboxReadData_markInboxRead;
import 'package:tendant/graphql/operations/__generated__/inbox_state.req.gql.dart'
    show GDismissInboxMessageReq, GMarkInboxReadReq;
import 'package:tendant/graphql/operations/__generated__/inbox_state.var.gql.dart'
    show GDismissInboxMessageVars, GMarkInboxReadVars;
import 'package:tendant/graphql/operations/__generated__/inbox_subscription.data.gql.dart'
    show
        GInboxEntryArrivedData_inboxEntryArrived_item,
        GInboxEntryArrivedData,
        GInboxEntryArrivedData_inboxEntryArrived,
        GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask,
        GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task,
        GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment,
        GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task,
        GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion,
        GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest,
        GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest,
        GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task,
        GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal,
        GInboxEntryArrivedData_inboxEntryArrived_item__base;
import 'package:tendant/graphql/operations/__generated__/inbox_subscription.req.gql.dart'
    show GInboxEntryArrivedReq;
import 'package:tendant/graphql/operations/__generated__/inbox_subscription.var.gql.dart'
    show GInboxEntryArrivedVars;
import 'package:tendant/graphql/operations/__generated__/pair_device.data.gql.dart'
    show
        GPairDeviceData,
        GPairDeviceData_pairDevice,
        GPairDeviceData_pairDevice_session;
import 'package:tendant/graphql/operations/__generated__/pair_device.req.gql.dart'
    show GPairDeviceReq;
import 'package:tendant/graphql/operations/__generated__/pair_device.var.gql.dart'
    show GPairDeviceVars;
import 'package:tendant/graphql/operations/__generated__/proposed_task.data.gql.dart'
    show
        GAcceptProposedTaskData,
        GAcceptProposedTaskData_acceptProposedTask,
        GDismissProposedTaskData,
        GDismissProposedTaskData_dismissProposedTask;
import 'package:tendant/graphql/operations/__generated__/proposed_task.req.gql.dart'
    show GAcceptProposedTaskReq, GDismissProposedTaskReq;
import 'package:tendant/graphql/operations/__generated__/proposed_task.var.gql.dart'
    show GAcceptProposedTaskVars, GDismissProposedTaskVars;
import 'package:tendant/graphql/operations/__generated__/register_device_token.data.gql.dart'
    show GRegisterDeviceTokenData, GUnregisterDeviceTokenData;
import 'package:tendant/graphql/operations/__generated__/register_device_token.req.gql.dart'
    show GRegisterDeviceTokenReq, GUnregisterDeviceTokenReq;
import 'package:tendant/graphql/operations/__generated__/register_device_token.var.gql.dart'
    show GRegisterDeviceTokenVars, GUnregisterDeviceTokenVars;
import 'package:tendant/graphql/operations/__generated__/routing.data.gql.dart'
    show
        GAgentConfigsData,
        GAgentConfigsData_agentConfigs,
        GTaskStageSlotsData,
        GTaskStageSlotsData_task,
        GTaskStageSlotsData_task_stageSlots,
        GTaskStageSlotsData_task_stageSlots_occupant;
import 'package:tendant/graphql/operations/__generated__/routing.req.gql.dart'
    show GAgentConfigsReq, GTaskStageSlotsReq;
import 'package:tendant/graphql/operations/__generated__/routing.var.gql.dart'
    show GAgentConfigsVars, GTaskStageSlotsVars;
import 'package:tendant/graphql/operations/__generated__/task_changed_subscription.data.gql.dart'
    show
        GTaskChangedData,
        GTaskChangedData_taskChanged,
        GTaskChangedData_taskChanged_openAssignment,
        GTaskChangedData_taskChanged_stageSlots,
        GTaskChangedData_taskChanged_stageSlots_occupant;
import 'package:tendant/graphql/operations/__generated__/task_changed_subscription.req.gql.dart'
    show GTaskChangedReq;
import 'package:tendant/graphql/operations/__generated__/task_changed_subscription.var.gql.dart'
    show GTaskChangedVars;
import 'package:tendant/graphql/operations/__generated__/task_detail.data.gql.dart'
    show
        GTaskDetailData,
        GTaskDetailData_task,
        GTaskDetailData_task_activity,
        GTaskDetailData_task_blockedBy,
        GTaskDetailData_task_blocks,
        GTaskDetailData_task_duplicateOf,
        GTaskDetailData_task_duplicates,
        GTaskDetailData_task_parent,
        GTaskDetailData_task_related,
        GTaskDetailData_task_stageSlots,
        GTaskDetailData_task_stageSlots_occupant,
        GTaskDetailData_task_subtasks,
        GTaskLinkData;
import 'package:tendant/graphql/operations/__generated__/task_detail.req.gql.dart'
    show GTaskDetailReq, GTaskLinkReq;
import 'package:tendant/graphql/operations/__generated__/task_detail.var.gql.dart'
    show GTaskDetailVars, GTaskLinkVars;
import 'package:tendant/graphql/operations/__generated__/task_relations.data.gql.dart'
    show
        GAddTaskRelationData,
        GAddTaskRelationData_addTaskRelation,
        GAddTaskRelationData_addTaskRelation_from,
        GAddTaskRelationData_addTaskRelation_to,
        GRemoveTaskRelationData;
import 'package:tendant/graphql/operations/__generated__/task_relations.req.gql.dart'
    show GAddTaskRelationReq, GRemoveTaskRelationReq;
import 'package:tendant/graphql/operations/__generated__/task_relations.var.gql.dart'
    show GAddTaskRelationVars, GRemoveTaskRelationVars;
import 'package:tendant/graphql/operations/__generated__/tasks.data.gql.dart'
    show
        GTasksData,
        GTasksData_tasks,
        GTasksData_tasks_edges,
        GTasksData_tasks_edges_node,
        GTasksData_tasks_edges_node_openAssignment,
        GTasksData_tasks_edges_node_stageSlots,
        GTasksData_tasks_edges_node_stageSlots_occupant,
        GTasksData_tasks_pageInfo;
import 'package:tendant/graphql/operations/__generated__/tasks.req.gql.dart'
    show GTasksReq;
import 'package:tendant/graphql/operations/__generated__/tasks.var.gql.dart'
    show GTasksVars;
import 'package:tendant/graphql/operations/__generated__/update_task_metadata.data.gql.dart'
    show GUpdateTaskMetadataData, GUpdateTaskMetadataData_updateTaskMetadata;
import 'package:tendant/graphql/operations/__generated__/update_task_metadata.req.gql.dart'
    show GUpdateTaskMetadataReq;
import 'package:tendant/graphql/operations/__generated__/update_task_metadata.var.gql.dart'
    show GUpdateTaskMetadataVars;
import 'package:tendant/graphql/queries/__generated__/categories.data.gql.dart'
    show
        GCategoriesData,
        GCategoriesData_categories,
        GCategoriesData_categories_parent,
        GDeleteTaskCategoryData,
        GSetTaskCategoryData,
        GSetTaskCategoryData_setTaskCategory;
import 'package:tendant/graphql/queries/__generated__/categories.req.gql.dart'
    show GCategoriesReq, GDeleteTaskCategoryReq, GSetTaskCategoryReq;
import 'package:tendant/graphql/queries/__generated__/categories.var.gql.dart'
    show GCategoriesVars, GDeleteTaskCategoryVars, GSetTaskCategoryVars;
import 'package:tendant/graphql/queries/__generated__/config.data.gql.dart'
    show
        GConfigKeysData,
        GConfigKeysData_configKeys,
        GDeleteConfigEntryData,
        GSetConfigEntryData,
        GSetConfigEntryData_setConfigEntry;
import 'package:tendant/graphql/queries/__generated__/config.req.gql.dart'
    show GConfigKeysReq, GDeleteConfigEntryReq, GSetConfigEntryReq;
import 'package:tendant/graphql/queries/__generated__/config.var.gql.dart'
    show GConfigKeysVars, GDeleteConfigEntryVars, GSetConfigEntryVars;
import 'package:tendant/graphql/queries/__generated__/connectors.data.gql.dart'
    show
        GConnectorsData,
        GConnectorsData_connectors,
        GEnableConnectorData,
        GEnableConnectorData_enableConnector,
        GSetConnectorConfigData,
        GSetConnectorConfigData_setConnectorConfig;
import 'package:tendant/graphql/queries/__generated__/connectors.req.gql.dart'
    show GConnectorsReq, GEnableConnectorReq, GSetConnectorConfigReq;
import 'package:tendant/graphql/queries/__generated__/connectors.var.gql.dart'
    show GConnectorsVars, GEnableConnectorVars, GSetConnectorConfigVars;

part 'serializers.gql.g.dart';

final SerializersBuilder _serializersBuilder = _$serializers.toBuilder()
  ..add(OperationSerializer())
  ..add(GFeedbackRequestData_pendingDecision.serializer)
  ..add(GInboxEntryArrivedData_inboxEntryArrived_item.serializer)
  ..add(GInboxFeedData_inboxFeed_entries_item.serializer)
  ..add(GPendingDecisionData_pendingDecision.serializer)
  ..add(GPendingDecisionData_pendingDecision__asApprovalRequest_payload
      .serializer)
  ..addPlugin(StandardJsonPlugin());
@SerializersFor([
  GAcceptFeedbackGuidanceData,
  GAcceptFeedbackGuidanceData_acceptFeedbackGuidance,
  GAcceptFeedbackGuidanceReq,
  GAcceptFeedbackGuidanceVars,
  GAcceptProposedTaskData,
  GAcceptProposedTaskData_acceptProposedTask,
  GAcceptProposedTaskReq,
  GAcceptProposedTaskVars,
  GAddTaskRelationData,
  GAddTaskRelationData_addTaskRelation,
  GAddTaskRelationData_addTaskRelation_from,
  GAddTaskRelationData_addTaskRelation_to,
  GAddTaskRelationReq,
  GAddTaskRelationVars,
  GAgentAssignmentData,
  GAgentAssignmentData_agentAssignment,
  GAgentAssignmentData_agentAssignment_task,
  GAgentAssignmentReq,
  GAgentAssignmentVars,
  GAgentConfigsData,
  GAgentConfigsData_agentConfigs,
  GAgentConfigsReq,
  GAgentConfigsVars,
  GAgentStage,
  GAnswerQuestionData,
  GAnswerQuestionData_answerQuestion,
  GAnswerQuestionReq,
  GAnswerQuestionVars,
  GApproveArtifactData,
  GApproveArtifactData_approveArtifact,
  GApproveArtifactReq,
  GApproveArtifactVars,
  GAutonomyLevel,
  GBytes,
  GCategoriesData,
  GCategoriesData_categories,
  GCategoriesData_categories_parent,
  GCategoriesReq,
  GCategoriesVars,
  GChainStage,
  GCompleteTaskData,
  GCompleteTaskData_completeTask,
  GCompleteTaskReq,
  GCompleteTaskVars,
  GConfigKeysData,
  GConfigKeysData_configKeys,
  GConfigKeysReq,
  GConfigKeysVars,
  GConnectorsData,
  GConnectorsData_connectors,
  GConnectorsReq,
  GConnectorsVars,
  GCreateTaskData,
  GCreateTaskData_createTask,
  GCreateTaskReq,
  GCreateTaskVars,
  GDeleteConfigEntryData,
  GDeleteConfigEntryReq,
  GDeleteConfigEntryVars,
  GDeleteTaskCategoryData,
  GDeleteTaskCategoryReq,
  GDeleteTaskCategoryVars,
  GDevicePlatform,
  GDismissFeedbackData,
  GDismissFeedbackData_dismissFeedback,
  GDismissFeedbackReq,
  GDismissFeedbackVars,
  GDismissInboxMessageData,
  GDismissInboxMessageData_dismissInboxMessage,
  GDismissInboxMessageReq,
  GDismissInboxMessageVars,
  GDismissProposedTaskData,
  GDismissProposedTaskData_dismissProposedTask,
  GDismissProposedTaskReq,
  GDismissProposedTaskVars,
  GEnableConnectorData,
  GEnableConnectorData_enableConnector,
  GEnableConnectorReq,
  GEnableConnectorVars,
  GFeedbackRequestData,
  GFeedbackRequestData_pendingDecision__asFeedbackRequest,
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_context,
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages,
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_task,
  GFeedbackRequestData_pendingDecision__base,
  GFeedbackRequestReq,
  GFeedbackRequestVars,
  GGateScriptStatus,
  GGateScriptTier,
  GGuidanceScope,
  GInboxEntryArrivedData,
  GInboxEntryArrivedData_inboxEntryArrived,
  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask,
  GInboxEntryArrivedData_inboxEntryArrived_item__asActionableTask_task,
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment,
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentAssignment_task,
  GInboxEntryArrivedData_inboxEntryArrived_item__asAgentQuestion,
  GInboxEntryArrivedData_inboxEntryArrived_item__asApprovalRequest,
  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest,
  GInboxEntryArrivedData_inboxEntryArrived_item__asFeedbackRequest_task,
  GInboxEntryArrivedData_inboxEntryArrived_item__asPromotionProposal,
  GInboxEntryArrivedData_inboxEntryArrived_item__base,
  GInboxEntryArrivedReq,
  GInboxEntryArrivedVars,
  GInboxFeedData,
  GInboxFeedData_inboxFeed,
  GInboxFeedData_inboxFeed_entries,
  GInboxFeedData_inboxFeed_entries_item__asActionableTask,
  GInboxFeedData_inboxFeed_entries_item__asActionableTask_task,
  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment,
  GInboxFeedData_inboxFeed_entries_item__asAgentAssignment_task,
  GInboxFeedData_inboxFeed_entries_item__asAgentQuestion,
  GInboxFeedData_inboxFeed_entries_item__asApprovalRequest,
  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest,
  GInboxFeedData_inboxFeed_entries_item__asFeedbackRequest_task,
  GInboxFeedData_inboxFeed_entries_item__asPromotionProposal,
  GInboxFeedData_inboxFeed_entries_item__base,
  GInboxFeedReq,
  GInboxFeedVars,
  GMarkInboxReadData,
  GMarkInboxReadData_markInboxRead,
  GMarkInboxReadReq,
  GMarkInboxReadVars,
  GPairDeviceData,
  GPairDeviceData_pairDevice,
  GPairDeviceData_pairDevice_session,
  GPairDeviceReq,
  GPairDeviceVars,
  GPendingDecisionData,
  GPendingDecisionData_pendingDecision__asAgentQuestion,
  GPendingDecisionData_pendingDecision__asAgentQuestion_asker,
  GPendingDecisionData_pendingDecision__asApprovalRequest,
  GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation,
  GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation,
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact,
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate,
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base,
  GPendingDecisionData_pendingDecision__asApprovalRequest_tool,
  GPendingDecisionData_pendingDecision__base,
  GPendingDecisionReq,
  GPendingDecisionVars,
  GRegisterDeviceTokenData,
  GRegisterDeviceTokenReq,
  GRegisterDeviceTokenVars,
  GRejectApprovalData,
  GRejectApprovalData_rejectApproval,
  GRejectApprovalReq,
  GRejectApprovalVars,
  GRemoveTaskRelationData,
  GRemoveTaskRelationReq,
  GRemoveTaskRelationVars,
  GSendFeedbackMessageData,
  GSendFeedbackMessageData_sendFeedbackMessage,
  GSendFeedbackMessageData_sendFeedbackMessage_messages,
  GSendFeedbackMessageReq,
  GSendFeedbackMessageVars,
  GSetConfigEntryData,
  GSetConfigEntryData_setConfigEntry,
  GSetConfigEntryReq,
  GSetConfigEntryVars,
  GSetConnectorConfigData,
  GSetConnectorConfigData_setConnectorConfig,
  GSetConnectorConfigReq,
  GSetConnectorConfigVars,
  GSetTaskCategoryData,
  GSetTaskCategoryData_setTaskCategory,
  GSetTaskCategoryInput,
  GSetTaskCategoryReq,
  GSetTaskCategoryVars,
  GTaskChangedData,
  GTaskChangedData_taskChanged,
  GTaskChangedData_taskChanged_openAssignment,
  GTaskChangedData_taskChanged_stageSlots,
  GTaskChangedData_taskChanged_stageSlots_occupant,
  GTaskChangedReq,
  GTaskChangedVars,
  GTaskDetailData,
  GTaskDetailData_task,
  GTaskDetailData_task_activity,
  GTaskDetailData_task_blockedBy,
  GTaskDetailData_task_blocks,
  GTaskDetailData_task_duplicateOf,
  GTaskDetailData_task_duplicates,
  GTaskDetailData_task_parent,
  GTaskDetailData_task_related,
  GTaskDetailData_task_stageSlots,
  GTaskDetailData_task_stageSlots_occupant,
  GTaskDetailData_task_subtasks,
  GTaskDetailReq,
  GTaskDetailVars,
  GTaskLinkData,
  GTaskLinkReq,
  GTaskLinkVars,
  GTaskPriority,
  GTaskRelationKind,
  GTaskStageSlotsData,
  GTaskStageSlotsData_task,
  GTaskStageSlotsData_task_stageSlots,
  GTaskStageSlotsData_task_stageSlots_occupant,
  GTaskStageSlotsReq,
  GTaskStageSlotsVars,
  GTaskState,
  GTasksData,
  GTasksData_tasks,
  GTasksData_tasks_edges,
  GTasksData_tasks_edges_node,
  GTasksData_tasks_edges_node_openAssignment,
  GTasksData_tasks_edges_node_stageSlots,
  GTasksData_tasks_edges_node_stageSlots_occupant,
  GTasksData_tasks_pageInfo,
  GTasksReq,
  GTasksVars,
  GTime,
  GUnregisterDeviceTokenData,
  GUnregisterDeviceTokenReq,
  GUnregisterDeviceTokenVars,
  GUpdateTaskMetadataData,
  GUpdateTaskMetadataData_updateTaskMetadata,
  GUpdateTaskMetadataReq,
  GUpdateTaskMetadataVars,
])
final Serializers serializers = _serializersBuilder.build();
