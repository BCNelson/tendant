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
        GInboxData_inbox,
        GInboxData,
        GInboxData_inbox__asAgentAssignment,
        GInboxData_inbox__asAgentAssignment_task,
        GInboxData_inbox__asAgentQuestion,
        GInboxData_inbox__asApprovalRequest,
        GInboxData_inbox__asFeedbackRequest,
        GInboxData_inbox__asFeedbackRequest_task,
        GInboxData_inbox__asPromotionProposal,
        GInboxData_inbox__base;
import 'package:tendant/graphql/operations/__generated__/inbox.req.gql.dart'
    show GInboxReq;
import 'package:tendant/graphql/operations/__generated__/inbox.var.gql.dart'
    show GInboxVars;
import 'package:tendant/graphql/operations/__generated__/inbox_subscription.data.gql.dart'
    show
        GInboxItemArrivedData_inboxItemArrived,
        GInboxItemArrivedData,
        GInboxItemArrivedData_inboxItemArrived__asAgentAssignment,
        GInboxItemArrivedData_inboxItemArrived__asAgentQuestion,
        GInboxItemArrivedData_inboxItemArrived__asApprovalRequest,
        GInboxItemArrivedData_inboxItemArrived__asPromotionProposal,
        GInboxItemArrivedData_inboxItemArrived__base;
import 'package:tendant/graphql/operations/__generated__/inbox_subscription.req.gql.dart'
    show GInboxItemArrivedReq;
import 'package:tendant/graphql/operations/__generated__/inbox_subscription.var.gql.dart'
    show GInboxItemArrivedVars;
import 'package:tendant/graphql/operations/__generated__/pair_device.data.gql.dart'
    show
        GPairDeviceData,
        GPairDeviceData_pairDevice,
        GPairDeviceData_pairDevice_session;
import 'package:tendant/graphql/operations/__generated__/pair_device.req.gql.dart'
    show GPairDeviceReq;
import 'package:tendant/graphql/operations/__generated__/pair_device.var.gql.dart'
    show GPairDeviceVars;
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
    show GTaskChangedData, GTaskChangedData_taskChanged;
import 'package:tendant/graphql/operations/__generated__/task_changed_subscription.req.gql.dart'
    show GTaskChangedReq;
import 'package:tendant/graphql/operations/__generated__/task_changed_subscription.var.gql.dart'
    show GTaskChangedVars;
import 'package:tendant/graphql/operations/__generated__/task_detail.data.gql.dart'
    show
        GTaskDetailData,
        GTaskDetailData_task,
        GTaskDetailData_task_activity,
        GTaskDetailData_task_stageSlots,
        GTaskDetailData_task_stageSlots_occupant;
import 'package:tendant/graphql/operations/__generated__/task_detail.req.gql.dart'
    show GTaskDetailReq;
import 'package:tendant/graphql/operations/__generated__/task_detail.var.gql.dart'
    show GTaskDetailVars;
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
  ..add(GInboxData_inbox.serializer)
  ..add(GInboxItemArrivedData_inboxItemArrived.serializer)
  ..add(GPendingDecisionData_pendingDecision.serializer)
  ..add(GPendingDecisionData_pendingDecision__asApprovalRequest_payload
      .serializer)
  ..addPlugin(StandardJsonPlugin());
@SerializersFor([
  GAcceptFeedbackGuidanceData,
  GAcceptFeedbackGuidanceData_acceptFeedbackGuidance,
  GAcceptFeedbackGuidanceReq,
  GAcceptFeedbackGuidanceVars,
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
  GDevicePlatform,
  GDismissFeedbackData,
  GDismissFeedbackData_dismissFeedback,
  GDismissFeedbackReq,
  GDismissFeedbackVars,
  GEnableConnectorData,
  GEnableConnectorData_enableConnector,
  GEnableConnectorReq,
  GEnableConnectorVars,
  GFeedbackRequestData,
  GFeedbackRequestData_pendingDecision__asFeedbackRequest,
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages,
  GFeedbackRequestData_pendingDecision__asFeedbackRequest_task,
  GFeedbackRequestData_pendingDecision__base,
  GFeedbackRequestReq,
  GFeedbackRequestVars,
  GGateScriptStatus,
  GGateScriptTier,
  GGuidanceScope,
  GInboxData,
  GInboxData_inbox__asAgentAssignment,
  GInboxData_inbox__asAgentAssignment_task,
  GInboxData_inbox__asAgentQuestion,
  GInboxData_inbox__asApprovalRequest,
  GInboxData_inbox__asFeedbackRequest,
  GInboxData_inbox__asFeedbackRequest_task,
  GInboxData_inbox__asPromotionProposal,
  GInboxData_inbox__base,
  GInboxItemArrivedData,
  GInboxItemArrivedData_inboxItemArrived__asAgentAssignment,
  GInboxItemArrivedData_inboxItemArrived__asAgentQuestion,
  GInboxItemArrivedData_inboxItemArrived__asApprovalRequest,
  GInboxItemArrivedData_inboxItemArrived__asPromotionProposal,
  GInboxItemArrivedData_inboxItemArrived__base,
  GInboxItemArrivedReq,
  GInboxItemArrivedVars,
  GInboxReq,
  GInboxVars,
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
  GTaskChangedData,
  GTaskChangedData_taskChanged,
  GTaskChangedReq,
  GTaskChangedVars,
  GTaskDetailData,
  GTaskDetailData_task,
  GTaskDetailData_task_activity,
  GTaskDetailData_task_stageSlots,
  GTaskDetailData_task_stageSlots_occupant,
  GTaskDetailReq,
  GTaskDetailVars,
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
])
final Serializers serializers = _serializersBuilder.build();
