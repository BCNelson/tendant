// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add(FetchPolicy.serializer)
      ..add(GAcceptFeedbackGuidanceData.serializer)
      ..add(GAcceptFeedbackGuidanceData_acceptFeedbackGuidance.serializer)
      ..add(GAcceptFeedbackGuidanceReq.serializer)
      ..add(GAcceptFeedbackGuidanceVars.serializer)
      ..add(GAgentAssignmentData.serializer)
      ..add(GAgentAssignmentData_agentAssignment.serializer)
      ..add(GAgentAssignmentData_agentAssignment_task.serializer)
      ..add(GAgentAssignmentReq.serializer)
      ..add(GAgentAssignmentVars.serializer)
      ..add(GAgentConfigsData.serializer)
      ..add(GAgentConfigsData_agentConfigs.serializer)
      ..add(GAgentConfigsReq.serializer)
      ..add(GAgentConfigsVars.serializer)
      ..add(GAgentStage.serializer)
      ..add(GAnswerQuestionData.serializer)
      ..add(GAnswerQuestionData_answerQuestion.serializer)
      ..add(GAnswerQuestionReq.serializer)
      ..add(GAnswerQuestionVars.serializer)
      ..add(GApproveArtifactData.serializer)
      ..add(GApproveArtifactData_approveArtifact.serializer)
      ..add(GApproveArtifactReq.serializer)
      ..add(GApproveArtifactVars.serializer)
      ..add(GAutonomyLevel.serializer)
      ..add(GBytes.serializer)
      ..add(GCategoriesData.serializer)
      ..add(GCategoriesData_categories.serializer)
      ..add(GCategoriesData_categories_parent.serializer)
      ..add(GCategoriesReq.serializer)
      ..add(GCategoriesVars.serializer)
      ..add(GChainStage.serializer)
      ..add(GCompleteTaskData.serializer)
      ..add(GCompleteTaskData_completeTask.serializer)
      ..add(GCompleteTaskReq.serializer)
      ..add(GCompleteTaskVars.serializer)
      ..add(GConfigKeysData.serializer)
      ..add(GConfigKeysData_configKeys.serializer)
      ..add(GConfigKeysReq.serializer)
      ..add(GConfigKeysVars.serializer)
      ..add(GConnectorsData.serializer)
      ..add(GConnectorsData_connectors.serializer)
      ..add(GConnectorsReq.serializer)
      ..add(GConnectorsVars.serializer)
      ..add(GCreateTaskData.serializer)
      ..add(GCreateTaskData_createTask.serializer)
      ..add(GCreateTaskReq.serializer)
      ..add(GCreateTaskVars.serializer)
      ..add(GDeleteConfigEntryData.serializer)
      ..add(GDeleteConfigEntryReq.serializer)
      ..add(GDeleteConfigEntryVars.serializer)
      ..add(GDeleteTaskCategoryData.serializer)
      ..add(GDeleteTaskCategoryReq.serializer)
      ..add(GDeleteTaskCategoryVars.serializer)
      ..add(GDevicePlatform.serializer)
      ..add(GDismissFeedbackData.serializer)
      ..add(GDismissFeedbackData_dismissFeedback.serializer)
      ..add(GDismissFeedbackReq.serializer)
      ..add(GDismissFeedbackVars.serializer)
      ..add(GEnableConnectorData.serializer)
      ..add(GEnableConnectorData_enableConnector.serializer)
      ..add(GEnableConnectorReq.serializer)
      ..add(GEnableConnectorVars.serializer)
      ..add(GFeedbackRequestData.serializer)
      ..add(GFeedbackRequestData_pendingDecision__asFeedbackRequest.serializer)
      ..add(GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages
          .serializer)
      ..add(GFeedbackRequestData_pendingDecision__asFeedbackRequest_task
          .serializer)
      ..add(GFeedbackRequestData_pendingDecision__base.serializer)
      ..add(GFeedbackRequestReq.serializer)
      ..add(GFeedbackRequestVars.serializer)
      ..add(GGateScriptStatus.serializer)
      ..add(GGateScriptTier.serializer)
      ..add(GGuidanceScope.serializer)
      ..add(GInboxData.serializer)
      ..add(GInboxData_inbox__asAgentAssignment.serializer)
      ..add(GInboxData_inbox__asAgentAssignment_task.serializer)
      ..add(GInboxData_inbox__asAgentQuestion.serializer)
      ..add(GInboxData_inbox__asApprovalRequest.serializer)
      ..add(GInboxData_inbox__asFeedbackRequest.serializer)
      ..add(GInboxData_inbox__asFeedbackRequest_task.serializer)
      ..add(GInboxData_inbox__asPromotionProposal.serializer)
      ..add(GInboxData_inbox__base.serializer)
      ..add(GInboxItemArrivedData.serializer)
      ..add(
          GInboxItemArrivedData_inboxItemArrived__asAgentAssignment.serializer)
      ..add(GInboxItemArrivedData_inboxItemArrived__asAgentQuestion.serializer)
      ..add(
          GInboxItemArrivedData_inboxItemArrived__asApprovalRequest.serializer)
      ..add(
          GInboxItemArrivedData_inboxItemArrived__asFeedbackRequest.serializer)
      ..add(GInboxItemArrivedData_inboxItemArrived__asPromotionProposal
          .serializer)
      ..add(GInboxItemArrivedData_inboxItemArrived__base.serializer)
      ..add(GInboxItemArrivedReq.serializer)
      ..add(GInboxItemArrivedVars.serializer)
      ..add(GInboxReq.serializer)
      ..add(GInboxVars.serializer)
      ..add(GPairDeviceData.serializer)
      ..add(GPairDeviceData_pairDevice.serializer)
      ..add(GPairDeviceData_pairDevice_session.serializer)
      ..add(GPairDeviceReq.serializer)
      ..add(GPairDeviceVars.serializer)
      ..add(GPendingDecisionData.serializer)
      ..add(GPendingDecisionData_pendingDecision__asAgentQuestion.serializer)
      ..add(GPendingDecisionData_pendingDecision__asAgentQuestion_asker
          .serializer)
      ..add(GPendingDecisionData_pendingDecision__asApprovalRequest.serializer)
      ..add(
          GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
              .serializer)
      ..add(
          GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
              .serializer)
      ..add(
          GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact
              .serializer)
      ..add(
          GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate
              .serializer)
      ..add(
          GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base
              .serializer)
      ..add(GPendingDecisionData_pendingDecision__asApprovalRequest_tool
          .serializer)
      ..add(GPendingDecisionData_pendingDecision__base.serializer)
      ..add(GPendingDecisionReq.serializer)
      ..add(GPendingDecisionVars.serializer)
      ..add(GRegisterDeviceTokenData.serializer)
      ..add(GRegisterDeviceTokenReq.serializer)
      ..add(GRegisterDeviceTokenVars.serializer)
      ..add(GRejectApprovalData.serializer)
      ..add(GRejectApprovalData_rejectApproval.serializer)
      ..add(GRejectApprovalReq.serializer)
      ..add(GRejectApprovalVars.serializer)
      ..add(GSendFeedbackMessageData.serializer)
      ..add(GSendFeedbackMessageData_sendFeedbackMessage.serializer)
      ..add(GSendFeedbackMessageData_sendFeedbackMessage_messages.serializer)
      ..add(GSendFeedbackMessageReq.serializer)
      ..add(GSendFeedbackMessageVars.serializer)
      ..add(GSetConfigEntryData.serializer)
      ..add(GSetConfigEntryData_setConfigEntry.serializer)
      ..add(GSetConfigEntryReq.serializer)
      ..add(GSetConfigEntryVars.serializer)
      ..add(GSetConnectorConfigData.serializer)
      ..add(GSetConnectorConfigData_setConnectorConfig.serializer)
      ..add(GSetConnectorConfigReq.serializer)
      ..add(GSetConnectorConfigVars.serializer)
      ..add(GSetTaskCategoryData.serializer)
      ..add(GSetTaskCategoryData_setTaskCategory.serializer)
      ..add(GSetTaskCategoryInput.serializer)
      ..add(GSetTaskCategoryReq.serializer)
      ..add(GSetTaskCategoryVars.serializer)
      ..add(GTaskChangedData.serializer)
      ..add(GTaskChangedData_taskChanged.serializer)
      ..add(GTaskChangedReq.serializer)
      ..add(GTaskChangedVars.serializer)
      ..add(GTaskDetailData.serializer)
      ..add(GTaskDetailData_task.serializer)
      ..add(GTaskDetailData_task_activity.serializer)
      ..add(GTaskDetailData_task_stageSlots.serializer)
      ..add(GTaskDetailData_task_stageSlots_occupant.serializer)
      ..add(GTaskDetailReq.serializer)
      ..add(GTaskDetailVars.serializer)
      ..add(GTaskStageSlotsData.serializer)
      ..add(GTaskStageSlotsData_task.serializer)
      ..add(GTaskStageSlotsData_task_stageSlots.serializer)
      ..add(GTaskStageSlotsData_task_stageSlots_occupant.serializer)
      ..add(GTaskStageSlotsReq.serializer)
      ..add(GTaskStageSlotsVars.serializer)
      ..add(GTaskState.serializer)
      ..add(GTasksData.serializer)
      ..add(GTasksData_tasks.serializer)
      ..add(GTasksData_tasks_edges.serializer)
      ..add(GTasksData_tasks_edges_node.serializer)
      ..add(GTasksData_tasks_edges_node_openAssignment.serializer)
      ..add(GTasksData_tasks_edges_node_stageSlots.serializer)
      ..add(GTasksData_tasks_edges_node_stageSlots_occupant.serializer)
      ..add(GTasksData_tasks_pageInfo.serializer)
      ..add(GTasksReq.serializer)
      ..add(GTasksVars.serializer)
      ..add(GTime.serializer)
      ..add(GUnregisterDeviceTokenData.serializer)
      ..add(GUnregisterDeviceTokenReq.serializer)
      ..add(GUnregisterDeviceTokenVars.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GAgentConfigsData_agentConfigs)]),
          () => ListBuilder<GAgentConfigsData_agentConfigs>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GCategoriesData_categories)]),
          () => ListBuilder<GCategoriesData_categories>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GConfigKeysData_configKeys)]),
          () => ListBuilder<GConfigKeysData_configKeys>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GConnectorsData_connectors)]),
          () => ListBuilder<GConnectorsData_connectors>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages)
          ]),
          () => ListBuilder<
              GFeedbackRequestData_pendingDecision__asFeedbackRequest_messages>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GInboxData_inbox)]),
          () => ListBuilder<GInboxData_inbox>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GSendFeedbackMessageData_sendFeedbackMessage_messages)
          ]),
          () => ListBuilder<
              GSendFeedbackMessageData_sendFeedbackMessage_messages>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GTaskDetailData_task_stageSlots)]),
          () => ListBuilder<GTaskDetailData_task_stageSlots>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GTaskDetailData_task_activity)]),
          () => ListBuilder<GTaskDetailData_task_activity>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GTaskStageSlotsData_task_stageSlots)]),
          () => ListBuilder<GTaskStageSlotsData_task_stageSlots>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GTasksData_tasks_edges)]),
          () => ListBuilder<GTasksData_tasks_edges>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GTasksData_tasks_edges_node_stageSlots)]),
          () => ListBuilder<GTasksData_tasks_edges_node_stageSlots>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
