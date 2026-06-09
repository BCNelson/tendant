// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GPendingDecisionData> _$gPendingDecisionDataSerializer =
    _$GPendingDecisionDataSerializer();
Serializer<GPendingDecisionData_pendingDecision__base>
    _$gPendingDecisionDataPendingDecisionBaseSerializer =
    _$GPendingDecisionData_pendingDecision__baseSerializer();
Serializer<GPendingDecisionData_pendingDecision__asApprovalRequest>
    _$gPendingDecisionDataPendingDecisionAsApprovalRequestSerializer =
    _$GPendingDecisionData_pendingDecision__asApprovalRequestSerializer();
Serializer<GPendingDecisionData_pendingDecision__asApprovalRequest_tool>
    _$gPendingDecisionDataPendingDecisionAsApprovalRequestToolSerializer =
    _$GPendingDecisionData_pendingDecision__asApprovalRequest_toolSerializer();
Serializer<
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base>
    _$gPendingDecisionDataPendingDecisionAsApprovalRequestPayloadBaseSerializer =
    _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseSerializer();
Serializer<
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact>
    _$gPendingDecisionDataPendingDecisionAsApprovalRequestPayloadAsArtifactSerializer =
    _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactSerializer();
Serializer<
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate>
    _$gPendingDecisionDataPendingDecisionAsApprovalRequestPayloadAsMandateSerializer =
    _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateSerializer();
Serializer<
        GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation>
    _$gPendingDecisionDataPendingDecisionAsApprovalRequestOverseerEvaluationSerializer =
    _$GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationSerializer();
Serializer<
        GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation>
    _$gPendingDecisionDataPendingDecisionAsApprovalRequestGateScriptEvaluationSerializer =
    _$GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationSerializer();
Serializer<GPendingDecisionData_pendingDecision__asAgentQuestion>
    _$gPendingDecisionDataPendingDecisionAsAgentQuestionSerializer =
    _$GPendingDecisionData_pendingDecision__asAgentQuestionSerializer();
Serializer<GPendingDecisionData_pendingDecision__asAgentQuestion_asker>
    _$gPendingDecisionDataPendingDecisionAsAgentQuestionAskerSerializer =
    _$GPendingDecisionData_pendingDecision__asAgentQuestion_askerSerializer();
Serializer<GApproveArtifactData> _$gApproveArtifactDataSerializer =
    _$GApproveArtifactDataSerializer();
Serializer<GApproveArtifactData_approveArtifact>
    _$gApproveArtifactDataApproveArtifactSerializer =
    _$GApproveArtifactData_approveArtifactSerializer();
Serializer<GRejectApprovalData> _$gRejectApprovalDataSerializer =
    _$GRejectApprovalDataSerializer();
Serializer<GRejectApprovalData_rejectApproval>
    _$gRejectApprovalDataRejectApprovalSerializer =
    _$GRejectApprovalData_rejectApprovalSerializer();
Serializer<GAnswerQuestionData> _$gAnswerQuestionDataSerializer =
    _$GAnswerQuestionDataSerializer();
Serializer<GAnswerQuestionData_answerQuestion>
    _$gAnswerQuestionDataAnswerQuestionSerializer =
    _$GAnswerQuestionData_answerQuestionSerializer();

class _$GPendingDecisionDataSerializer
    implements StructuredSerializer<GPendingDecisionData> {
  @override
  final Iterable<Type> types = const [
    GPendingDecisionData,
    _$GPendingDecisionData
  ];
  @override
  final String wireName = 'GPendingDecisionData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GPendingDecisionData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.pendingDecision;
    if (value != null) {
      result
        ..add('pendingDecision')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(GPendingDecisionData_pendingDecision)));
    }
    return result;
  }

  @override
  GPendingDecisionData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GPendingDecisionDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'pendingDecision':
          result.pendingDecision = serializers.deserialize(value,
                  specifiedType:
                      const FullType(GPendingDecisionData_pendingDecision))
              as GPendingDecisionData_pendingDecision?;
          break;
      }
    }

    return result.build();
  }
}

class _$GPendingDecisionData_pendingDecision__baseSerializer
    implements
        StructuredSerializer<GPendingDecisionData_pendingDecision__base> {
  @override
  final Iterable<Type> types = const [
    GPendingDecisionData_pendingDecision__base,
    _$GPendingDecisionData_pendingDecision__base
  ];
  @override
  final String wireName = 'GPendingDecisionData_pendingDecision__base';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GPendingDecisionData_pendingDecision__base object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i2.GTime)),
    ];

    return result;
  }

  @override
  GPendingDecisionData_pendingDecision__base deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GPendingDecisionData_pendingDecision__baseBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
      }
    }

    return result.build();
  }
}

class _$GPendingDecisionData_pendingDecision__asApprovalRequestSerializer
    implements
        StructuredSerializer<
            GPendingDecisionData_pendingDecision__asApprovalRequest> {
  @override
  final Iterable<Type> types = const [
    GPendingDecisionData_pendingDecision__asApprovalRequest,
    _$GPendingDecisionData_pendingDecision__asApprovalRequest
  ];
  @override
  final String wireName =
      'GPendingDecisionData_pendingDecision__asApprovalRequest';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GPendingDecisionData_pendingDecision__asApprovalRequest object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i2.GTime)),
      'tool',
      serializers.serialize(object.tool,
          specifiedType: const FullType(
              GPendingDecisionData_pendingDecision__asApprovalRequest_tool)),
      'payload',
      serializers.serialize(object.payload,
          specifiedType: const FullType(
              GPendingDecisionData_pendingDecision__asApprovalRequest_payload)),
    ];
    Object? value;
    value = object.overseerEvaluation;
    if (value != null) {
      result
        ..add('overseerEvaluation')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation)));
    }
    value = object.gateScriptEvaluation;
    if (value != null) {
      result
        ..add('gateScriptEvaluation')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation)));
    }
    return result;
  }

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GPendingDecisionData_pendingDecision__asApprovalRequestBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'tool':
          result.tool.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GPendingDecisionData_pendingDecision__asApprovalRequest_tool))!
              as GPendingDecisionData_pendingDecision__asApprovalRequest_tool);
          break;
        case 'payload':
          result.payload = serializers.deserialize(value,
                  specifiedType: const FullType(
                      GPendingDecisionData_pendingDecision__asApprovalRequest_payload))!
              as GPendingDecisionData_pendingDecision__asApprovalRequest_payload;
          break;
        case 'overseerEvaluation':
          result.overseerEvaluation.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation))!
              as GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation);
          break;
        case 'gateScriptEvaluation':
          result.gateScriptEvaluation.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation))!
              as GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation);
          break;
      }
    }

    return result.build();
  }
}

class _$GPendingDecisionData_pendingDecision__asApprovalRequest_toolSerializer
    implements
        StructuredSerializer<
            GPendingDecisionData_pendingDecision__asApprovalRequest_tool> {
  @override
  final Iterable<Type> types = const [
    GPendingDecisionData_pendingDecision__asApprovalRequest_tool,
    _$GPendingDecisionData_pendingDecision__asApprovalRequest_tool
  ];
  @override
  final String wireName =
      'GPendingDecisionData_pendingDecision__asApprovalRequest_tool';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GPendingDecisionData_pendingDecision__asApprovalRequest_tool object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'globalUri',
      serializers.serialize(object.globalUri,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_tool deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'globalUri':
          result.globalUri = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseSerializer
    implements
        StructuredSerializer<
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base> {
  @override
  final Iterable<Type> types = const [
    GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base,
    _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base
  ];
  @override
  final String wireName =
      'GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base';

  @override
  Iterable<Object?> serialize(
      Serializers serializers,
      GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base
          object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base
      deserialize(Serializers serializers, Iterable<Object?> serialized,
          {FullType specifiedType = FullType.unspecified}) {
    final result =
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactSerializer
    implements
        StructuredSerializer<
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact> {
  @override
  final Iterable<Type> types = const [
    GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact,
    _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact
  ];
  @override
  final String wireName =
      'GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact';

  @override
  Iterable<Object?> serialize(
      Serializers serializers,
      GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact
          object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'kind',
      serializers.serialize(object.kind, specifiedType: const FullType(String)),
      'content',
      serializers.serialize(object.content,
          specifiedType: const FullType(_i4.JsonObject)),
    ];
    Object? value;
    value = object.recipient;
    if (value != null) {
      result
        ..add('recipient')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact
      deserialize(Serializers serializers, Iterable<Object?> serialized,
          {FullType specifiedType = FullType.unspecified}) {
    final result =
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'kind':
          result.kind = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'content':
          result.content = serializers.deserialize(value,
              specifiedType: const FullType(_i4.JsonObject))! as _i4.JsonObject;
          break;
        case 'recipient':
          result.recipient = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateSerializer
    implements
        StructuredSerializer<
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate> {
  @override
  final Iterable<Type> types = const [
    GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate,
    _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate
  ];
  @override
  final String wireName =
      'GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate';

  @override
  Iterable<Object?> serialize(
      Serializers serializers,
      GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate
          object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'goal',
      serializers.serialize(object.goal, specifiedType: const FullType(String)),
      'constraints',
      serializers.serialize(object.constraints,
          specifiedType: const FullType(_i4.JsonObject)),
      'guardrails',
      serializers.serialize(object.guardrails,
          specifiedType: const FullType(_i4.JsonObject)),
    ];

    return result;
  }

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate
      deserialize(Serializers serializers, Iterable<Object?> serialized,
          {FullType specifiedType = FullType.unspecified}) {
    final result =
        GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'goal':
          result.goal = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'constraints':
          result.constraints = serializers.deserialize(value,
              specifiedType: const FullType(_i4.JsonObject))! as _i4.JsonObject;
          break;
        case 'guardrails':
          result.guardrails = serializers.deserialize(value,
              specifiedType: const FullType(_i4.JsonObject))! as _i4.JsonObject;
          break;
      }
    }

    return result.build();
  }
}

class _$GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationSerializer
    implements
        StructuredSerializer<
            GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation> {
  @override
  final Iterable<Type> types = const [
    GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation,
    _$GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
  ];
  @override
  final String wireName =
      'GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation';

  @override
  Iterable<Object?> serialize(
      Serializers serializers,
      GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
          object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'verdict',
      serializers.serialize(object.verdict,
          specifiedType: const FullType(String)),
      'summary',
      serializers.serialize(object.summary,
          specifiedType: const FullType(String)),
      'consideredFields',
      serializers.serialize(object.consideredFields,
          specifiedType:
              const FullType(BuiltList, const [const FullType(String)])),
      'modelId',
      serializers.serialize(object.modelId,
          specifiedType: const FullType(String)),
      'provider',
      serializers.serialize(object.provider,
          specifiedType: const FullType(String)),
      'tokensIn',
      serializers.serialize(object.tokensIn,
          specifiedType: const FullType(int)),
      'tokensOut',
      serializers.serialize(object.tokensOut,
          specifiedType: const FullType(int)),
      'estimatedCostUsd',
      serializers.serialize(object.estimatedCostUsd,
          specifiedType: const FullType(double)),
      'at',
      serializers.serialize(object.at,
          specifiedType: const FullType(_i2.GTime)),
    ];

    return result;
  }

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
      deserialize(Serializers serializers, Iterable<Object?> serialized,
          {FullType specifiedType = FullType.unspecified}) {
    final result =
        GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'verdict':
          result.verdict = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'summary':
          result.summary = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'consideredFields':
          result.consideredFields.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'modelId':
          result.modelId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'provider':
          result.provider = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'tokensIn':
          result.tokensIn = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'tokensOut':
          result.tokensOut = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'estimatedCostUsd':
          result.estimatedCostUsd = serializers.deserialize(value,
              specifiedType: const FullType(double))! as double;
          break;
        case 'at':
          result.at.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
      }
    }

    return result.build();
  }
}

class _$GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationSerializer
    implements
        StructuredSerializer<
            GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation> {
  @override
  final Iterable<Type> types = const [
    GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation,
    _$GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
  ];
  @override
  final String wireName =
      'GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation';

  @override
  Iterable<Object?> serialize(
      Serializers serializers,
      GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
          object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'verdict',
      serializers.serialize(object.verdict,
          specifiedType: const FullType(String)),
      'summary',
      serializers.serialize(object.summary,
          specifiedType: const FullType(String)),
      'consideredFields',
      serializers.serialize(object.consideredFields,
          specifiedType:
              const FullType(BuiltList, const [const FullType(String)])),
      'hostcallTrace',
      serializers.serialize(object.hostcallTrace,
          specifiedType:
              const FullType(BuiltList, const [const FullType(String)])),
      'scriptVersion',
      serializers.serialize(object.scriptVersion,
          specifiedType: const FullType(int)),
      'at',
      serializers.serialize(object.at,
          specifiedType: const FullType(_i2.GTime)),
    ];

    return result;
  }

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
      deserialize(Serializers serializers, Iterable<Object?> serialized,
          {FullType specifiedType = FullType.unspecified}) {
    final result =
        GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'verdict':
          result.verdict = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'summary':
          result.summary = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'consideredFields':
          result.consideredFields.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'hostcallTrace':
          result.hostcallTrace.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'scriptVersion':
          result.scriptVersion = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'at':
          result.at.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
      }
    }

    return result.build();
  }
}

class _$GPendingDecisionData_pendingDecision__asAgentQuestionSerializer
    implements
        StructuredSerializer<
            GPendingDecisionData_pendingDecision__asAgentQuestion> {
  @override
  final Iterable<Type> types = const [
    GPendingDecisionData_pendingDecision__asAgentQuestion,
    _$GPendingDecisionData_pendingDecision__asAgentQuestion
  ];
  @override
  final String wireName =
      'GPendingDecisionData_pendingDecision__asAgentQuestion';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GPendingDecisionData_pendingDecision__asAgentQuestion object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i2.GTime)),
      'asker',
      serializers.serialize(object.asker,
          specifiedType: const FullType(
              GPendingDecisionData_pendingDecision__asAgentQuestion_asker)),
      'question',
      serializers.serialize(object.question,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.disclosureClass;
    if (value != null) {
      result
        ..add('disclosureClass')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GPendingDecisionData_pendingDecision__asAgentQuestion deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GPendingDecisionData_pendingDecision__asAgentQuestionBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'asker':
          result.asker.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GPendingDecisionData_pendingDecision__asAgentQuestion_asker))!
              as GPendingDecisionData_pendingDecision__asAgentQuestion_asker);
          break;
        case 'question':
          result.question = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'disclosureClass':
          result.disclosureClass = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GPendingDecisionData_pendingDecision__asAgentQuestion_askerSerializer
    implements
        StructuredSerializer<
            GPendingDecisionData_pendingDecision__asAgentQuestion_asker> {
  @override
  final Iterable<Type> types = const [
    GPendingDecisionData_pendingDecision__asAgentQuestion_asker,
    _$GPendingDecisionData_pendingDecision__asAgentQuestion_asker
  ];
  @override
  final String wireName =
      'GPendingDecisionData_pendingDecision__asAgentQuestion_asker';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GPendingDecisionData_pendingDecision__asAgentQuestion_asker object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'displayName',
      serializers.serialize(object.displayName,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GPendingDecisionData_pendingDecision__asAgentQuestion_asker deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'displayName':
          result.displayName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GApproveArtifactDataSerializer
    implements StructuredSerializer<GApproveArtifactData> {
  @override
  final Iterable<Type> types = const [
    GApproveArtifactData,
    _$GApproveArtifactData
  ];
  @override
  final String wireName = 'GApproveArtifactData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GApproveArtifactData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'approveArtifact',
      serializers.serialize(object.approveArtifact,
          specifiedType: const FullType(GApproveArtifactData_approveArtifact)),
    ];

    return result;
  }

  @override
  GApproveArtifactData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GApproveArtifactDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'approveArtifact':
          result.approveArtifact.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GApproveArtifactData_approveArtifact))!
              as GApproveArtifactData_approveArtifact);
          break;
      }
    }

    return result.build();
  }
}

class _$GApproveArtifactData_approveArtifactSerializer
    implements StructuredSerializer<GApproveArtifactData_approveArtifact> {
  @override
  final Iterable<Type> types = const [
    GApproveArtifactData_approveArtifact,
    _$GApproveArtifactData_approveArtifact
  ];
  @override
  final String wireName = 'GApproveArtifactData_approveArtifact';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GApproveArtifactData_approveArtifact object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GApproveArtifactData_approveArtifact deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GApproveArtifactData_approveArtifactBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GRejectApprovalDataSerializer
    implements StructuredSerializer<GRejectApprovalData> {
  @override
  final Iterable<Type> types = const [
    GRejectApprovalData,
    _$GRejectApprovalData
  ];
  @override
  final String wireName = 'GRejectApprovalData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GRejectApprovalData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'rejectApproval',
      serializers.serialize(object.rejectApproval,
          specifiedType: const FullType(GRejectApprovalData_rejectApproval)),
    ];

    return result;
  }

  @override
  GRejectApprovalData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GRejectApprovalDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'rejectApproval':
          result.rejectApproval.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GRejectApprovalData_rejectApproval))!
              as GRejectApprovalData_rejectApproval);
          break;
      }
    }

    return result.build();
  }
}

class _$GRejectApprovalData_rejectApprovalSerializer
    implements StructuredSerializer<GRejectApprovalData_rejectApproval> {
  @override
  final Iterable<Type> types = const [
    GRejectApprovalData_rejectApproval,
    _$GRejectApprovalData_rejectApproval
  ];
  @override
  final String wireName = 'GRejectApprovalData_rejectApproval';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GRejectApprovalData_rejectApproval object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GRejectApprovalData_rejectApproval deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GRejectApprovalData_rejectApprovalBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GAnswerQuestionDataSerializer
    implements StructuredSerializer<GAnswerQuestionData> {
  @override
  final Iterable<Type> types = const [
    GAnswerQuestionData,
    _$GAnswerQuestionData
  ];
  @override
  final String wireName = 'GAnswerQuestionData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAnswerQuestionData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'answerQuestion',
      serializers.serialize(object.answerQuestion,
          specifiedType: const FullType(GAnswerQuestionData_answerQuestion)),
    ];

    return result;
  }

  @override
  GAnswerQuestionData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAnswerQuestionDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'answerQuestion':
          result.answerQuestion.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GAnswerQuestionData_answerQuestion))!
              as GAnswerQuestionData_answerQuestion);
          break;
      }
    }

    return result.build();
  }
}

class _$GAnswerQuestionData_answerQuestionSerializer
    implements StructuredSerializer<GAnswerQuestionData_answerQuestion> {
  @override
  final Iterable<Type> types = const [
    GAnswerQuestionData_answerQuestion,
    _$GAnswerQuestionData_answerQuestion
  ];
  @override
  final String wireName = 'GAnswerQuestionData_answerQuestion';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAnswerQuestionData_answerQuestion object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GAnswerQuestionData_answerQuestion deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAnswerQuestionData_answerQuestionBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GPendingDecisionData extends GPendingDecisionData {
  @override
  final String G__typename;
  @override
  final GPendingDecisionData_pendingDecision? pendingDecision;

  factory _$GPendingDecisionData(
          [void Function(GPendingDecisionDataBuilder)? updates]) =>
      (GPendingDecisionDataBuilder()..update(updates))._build();

  _$GPendingDecisionData._({required this.G__typename, this.pendingDecision})
      : super._();
  @override
  GPendingDecisionData rebuild(
          void Function(GPendingDecisionDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPendingDecisionDataBuilder toBuilder() =>
      GPendingDecisionDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GPendingDecisionData &&
        G__typename == other.G__typename &&
        pendingDecision == other.pendingDecision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, pendingDecision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GPendingDecisionData')
          ..add('G__typename', G__typename)
          ..add('pendingDecision', pendingDecision))
        .toString();
  }
}

class GPendingDecisionDataBuilder
    implements Builder<GPendingDecisionData, GPendingDecisionDataBuilder> {
  _$GPendingDecisionData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GPendingDecisionData_pendingDecision? _pendingDecision;
  GPendingDecisionData_pendingDecision? get pendingDecision =>
      _$this._pendingDecision;
  set pendingDecision(GPendingDecisionData_pendingDecision? pendingDecision) =>
      _$this._pendingDecision = pendingDecision;

  GPendingDecisionDataBuilder() {
    GPendingDecisionData._initializeBuilder(this);
  }

  GPendingDecisionDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _pendingDecision = $v.pendingDecision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GPendingDecisionData other) {
    _$v = other as _$GPendingDecisionData;
  }

  @override
  void update(void Function(GPendingDecisionDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GPendingDecisionData build() => _build();

  _$GPendingDecisionData _build() {
    final _$result = _$v ??
        _$GPendingDecisionData._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GPendingDecisionData', 'G__typename'),
          pendingDecision: pendingDecision,
        );
    replace(_$result);
    return _$result;
  }
}

class _$GPendingDecisionData_pendingDecision__base
    extends GPendingDecisionData_pendingDecision__base {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GTime createdAt;

  factory _$GPendingDecisionData_pendingDecision__base(
          [void Function(GPendingDecisionData_pendingDecision__baseBuilder)?
              updates]) =>
      (GPendingDecisionData_pendingDecision__baseBuilder()..update(updates))
          ._build();

  _$GPendingDecisionData_pendingDecision__base._(
      {required this.G__typename, required this.id, required this.createdAt})
      : super._();
  @override
  GPendingDecisionData_pendingDecision__base rebuild(
          void Function(GPendingDecisionData_pendingDecision__baseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPendingDecisionData_pendingDecision__baseBuilder toBuilder() =>
      GPendingDecisionData_pendingDecision__baseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GPendingDecisionData_pendingDecision__base &&
        G__typename == other.G__typename &&
        id == other.id &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GPendingDecisionData_pendingDecision__base')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class GPendingDecisionData_pendingDecision__baseBuilder
    implements
        Builder<GPendingDecisionData_pendingDecision__base,
            GPendingDecisionData_pendingDecision__baseBuilder> {
  _$GPendingDecisionData_pendingDecision__base? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GTimeBuilder? _createdAt;
  _i2.GTimeBuilder get createdAt => _$this._createdAt ??= _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GPendingDecisionData_pendingDecision__baseBuilder() {
    GPendingDecisionData_pendingDecision__base._initializeBuilder(this);
  }

  GPendingDecisionData_pendingDecision__baseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _createdAt = $v.createdAt.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GPendingDecisionData_pendingDecision__base other) {
    _$v = other as _$GPendingDecisionData_pendingDecision__base;
  }

  @override
  void update(
      void Function(GPendingDecisionData_pendingDecision__baseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GPendingDecisionData_pendingDecision__base build() => _build();

  _$GPendingDecisionData_pendingDecision__base _build() {
    _$GPendingDecisionData_pendingDecision__base _$result;
    try {
      _$result = _$v ??
          _$GPendingDecisionData_pendingDecision__base._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GPendingDecisionData_pendingDecision__base', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GPendingDecisionData_pendingDecision__base', 'id'),
            createdAt: createdAt.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GPendingDecisionData_pendingDecision__base',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GPendingDecisionData_pendingDecision__asApprovalRequest
    extends GPendingDecisionData_pendingDecision__asApprovalRequest {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GTime createdAt;
  @override
  final GPendingDecisionData_pendingDecision__asApprovalRequest_tool tool;
  @override
  final GPendingDecisionData_pendingDecision__asApprovalRequest_payload payload;
  @override
  final GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation?
      overseerEvaluation;
  @override
  final GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation?
      gateScriptEvaluation;

  factory _$GPendingDecisionData_pendingDecision__asApprovalRequest(
          [void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequestBuilder)?
              updates]) =>
      (GPendingDecisionData_pendingDecision__asApprovalRequestBuilder()
            ..update(updates))
          ._build();

  _$GPendingDecisionData_pendingDecision__asApprovalRequest._(
      {required this.G__typename,
      required this.id,
      required this.createdAt,
      required this.tool,
      required this.payload,
      this.overseerEvaluation,
      this.gateScriptEvaluation})
      : super._();
  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest rebuild(
          void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequestBuilder toBuilder() =>
      GPendingDecisionData_pendingDecision__asApprovalRequestBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GPendingDecisionData_pendingDecision__asApprovalRequest &&
        G__typename == other.G__typename &&
        id == other.id &&
        createdAt == other.createdAt &&
        tool == other.tool &&
        payload == other.payload &&
        overseerEvaluation == other.overseerEvaluation &&
        gateScriptEvaluation == other.gateScriptEvaluation;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, tool.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jc(_$hash, overseerEvaluation.hashCode);
    _$hash = $jc(_$hash, gateScriptEvaluation.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GPendingDecisionData_pendingDecision__asApprovalRequest')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('createdAt', createdAt)
          ..add('tool', tool)
          ..add('payload', payload)
          ..add('overseerEvaluation', overseerEvaluation)
          ..add('gateScriptEvaluation', gateScriptEvaluation))
        .toString();
  }
}

class GPendingDecisionData_pendingDecision__asApprovalRequestBuilder
    implements
        Builder<GPendingDecisionData_pendingDecision__asApprovalRequest,
            GPendingDecisionData_pendingDecision__asApprovalRequestBuilder> {
  _$GPendingDecisionData_pendingDecision__asApprovalRequest? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GTimeBuilder? _createdAt;
  _i2.GTimeBuilder get createdAt => _$this._createdAt ??= _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder? _tool;
  GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder
      get tool => _$this._tool ??=
          GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder();
  set tool(
          GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder?
              tool) =>
      _$this._tool = tool;

  GPendingDecisionData_pendingDecision__asApprovalRequest_payload? _payload;
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload?
      get payload => _$this._payload;
  set payload(
          GPendingDecisionData_pendingDecision__asApprovalRequest_payload?
              payload) =>
      _$this._payload = payload;

  GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder?
      _overseerEvaluation;
  GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder
      get overseerEvaluation => _$this._overseerEvaluation ??=
          GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder();
  set overseerEvaluation(
          GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder?
              overseerEvaluation) =>
      _$this._overseerEvaluation = overseerEvaluation;

  GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder?
      _gateScriptEvaluation;
  GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder
      get gateScriptEvaluation => _$this._gateScriptEvaluation ??=
          GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder();
  set gateScriptEvaluation(
          GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder?
              gateScriptEvaluation) =>
      _$this._gateScriptEvaluation = gateScriptEvaluation;

  GPendingDecisionData_pendingDecision__asApprovalRequestBuilder() {
    GPendingDecisionData_pendingDecision__asApprovalRequest._initializeBuilder(
        this);
  }

  GPendingDecisionData_pendingDecision__asApprovalRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _createdAt = $v.createdAt.toBuilder();
      _tool = $v.tool.toBuilder();
      _payload = $v.payload;
      _overseerEvaluation = $v.overseerEvaluation?.toBuilder();
      _gateScriptEvaluation = $v.gateScriptEvaluation?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GPendingDecisionData_pendingDecision__asApprovalRequest other) {
    _$v = other as _$GPendingDecisionData_pendingDecision__asApprovalRequest;
  }

  @override
  void update(
      void Function(
              GPendingDecisionData_pendingDecision__asApprovalRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest build() => _build();

  _$GPendingDecisionData_pendingDecision__asApprovalRequest _build() {
    _$GPendingDecisionData_pendingDecision__asApprovalRequest _$result;
    try {
      _$result = _$v ??
          _$GPendingDecisionData_pendingDecision__asApprovalRequest._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest',
                'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest',
                'id'),
            createdAt: createdAt.build(),
            tool: tool.build(),
            payload: BuiltValueNullFieldError.checkNotNull(
                payload,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest',
                'payload'),
            overseerEvaluation: _overseerEvaluation?.build(),
            gateScriptEvaluation: _gateScriptEvaluation?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
        _$failedField = 'tool';
        tool.build();

        _$failedField = 'overseerEvaluation';
        _overseerEvaluation?.build();
        _$failedField = 'gateScriptEvaluation';
        _gateScriptEvaluation?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GPendingDecisionData_pendingDecision__asApprovalRequest',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GPendingDecisionData_pendingDecision__asApprovalRequest_tool
    extends GPendingDecisionData_pendingDecision__asApprovalRequest_tool {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String name;
  @override
  final String globalUri;

  factory _$GPendingDecisionData_pendingDecision__asApprovalRequest_tool(
          [void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder)?
              updates]) =>
      (GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder()
            ..update(updates))
          ._build();

  _$GPendingDecisionData_pendingDecision__asApprovalRequest_tool._(
      {required this.G__typename,
      required this.id,
      required this.name,
      required this.globalUri})
      : super._();
  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_tool rebuild(
          void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder
      toBuilder() =>
          GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GPendingDecisionData_pendingDecision__asApprovalRequest_tool &&
        G__typename == other.G__typename &&
        id == other.id &&
        name == other.name &&
        globalUri == other.globalUri;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, globalUri.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GPendingDecisionData_pendingDecision__asApprovalRequest_tool')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('name', name)
          ..add('globalUri', globalUri))
        .toString();
  }
}

class GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder
    implements
        Builder<GPendingDecisionData_pendingDecision__asApprovalRequest_tool,
            GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder> {
  _$GPendingDecisionData_pendingDecision__asApprovalRequest_tool? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _globalUri;
  String? get globalUri => _$this._globalUri;
  set globalUri(String? globalUri) => _$this._globalUri = globalUri;

  GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder() {
    GPendingDecisionData_pendingDecision__asApprovalRequest_tool
        ._initializeBuilder(this);
  }

  GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _name = $v.name;
      _globalUri = $v.globalUri;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GPendingDecisionData_pendingDecision__asApprovalRequest_tool other) {
    _$v =
        other as _$GPendingDecisionData_pendingDecision__asApprovalRequest_tool;
  }

  @override
  void update(
      void Function(
              GPendingDecisionData_pendingDecision__asApprovalRequest_toolBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_tool build() =>
      _build();

  _$GPendingDecisionData_pendingDecision__asApprovalRequest_tool _build() {
    final _$result = _$v ??
        _$GPendingDecisionData_pendingDecision__asApprovalRequest_tool._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GPendingDecisionData_pendingDecision__asApprovalRequest_tool',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GPendingDecisionData_pendingDecision__asApprovalRequest_tool',
              'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'GPendingDecisionData_pendingDecision__asApprovalRequest_tool',
              'name'),
          globalUri: BuiltValueNullFieldError.checkNotNull(
              globalUri,
              r'GPendingDecisionData_pendingDecision__asApprovalRequest_tool',
              'globalUri'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base
    extends GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base {
  @override
  final String G__typename;

  factory _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base(
          [void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseBuilder)?
              updates]) =>
      (GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseBuilder()
            ..update(updates))
          ._build();

  _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base._(
      {required this.G__typename})
      : super._();
  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base rebuild(
          void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseBuilder
      toBuilder() =>
          GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base &&
        G__typename == other.G__typename;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base')
          ..add('G__typename', G__typename))
        .toString();
  }
}

class GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseBuilder
    implements
        Builder<
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base,
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseBuilder> {
  _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseBuilder() {
    GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base
        ._initializeBuilder(this);
  }

  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base
          other) {
    _$v = other
        as _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base;
  }

  @override
  void update(
      void Function(
              GPendingDecisionData_pendingDecision__asApprovalRequest_payload__baseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base
      build() => _build();

  _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base
      _build() {
    final _$result = _$v ??
        _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base
            ._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GPendingDecisionData_pendingDecision__asApprovalRequest_payload__base',
              'G__typename'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact
    extends GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact {
  @override
  final String G__typename;
  @override
  final String kind;
  @override
  final _i4.JsonObject content;
  @override
  final String? recipient;

  factory _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact(
          [void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactBuilder)?
              updates]) =>
      (GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactBuilder()
            ..update(updates))
          ._build();

  _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact._(
      {required this.G__typename,
      required this.kind,
      required this.content,
      this.recipient})
      : super._();
  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact
      rebuild(
              void Function(
                      GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactBuilder
      toBuilder() =>
          GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact &&
        G__typename == other.G__typename &&
        kind == other.kind &&
        content == other.content &&
        recipient == other.recipient;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, recipient.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact')
          ..add('G__typename', G__typename)
          ..add('kind', kind)
          ..add('content', content)
          ..add('recipient', recipient))
        .toString();
  }
}

class GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactBuilder
    implements
        Builder<
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact,
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactBuilder> {
  _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact?
      _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _kind;
  String? get kind => _$this._kind;
  set kind(String? kind) => _$this._kind = kind;

  _i4.JsonObject? _content;
  _i4.JsonObject? get content => _$this._content;
  set content(_i4.JsonObject? content) => _$this._content = content;

  String? _recipient;
  String? get recipient => _$this._recipient;
  set recipient(String? recipient) => _$this._recipient = recipient;

  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactBuilder() {
    GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact
        ._initializeBuilder(this);
  }

  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _kind = $v.kind;
      _content = $v.content;
      _recipient = $v.recipient;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact
          other) {
    _$v = other
        as _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact;
  }

  @override
  void update(
      void Function(
              GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifactBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact
      build() => _build();

  _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact
      _build() {
    final _$result = _$v ??
        _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact
            ._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact',
              'G__typename'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind,
              r'GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact',
              'kind'),
          content: BuiltValueNullFieldError.checkNotNull(
              content,
              r'GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asArtifact',
              'content'),
          recipient: recipient,
        );
    replace(_$result);
    return _$result;
  }
}

class _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate
    extends GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate {
  @override
  final String G__typename;
  @override
  final String goal;
  @override
  final _i4.JsonObject constraints;
  @override
  final _i4.JsonObject guardrails;

  factory _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate(
          [void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateBuilder)?
              updates]) =>
      (GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateBuilder()
            ..update(updates))
          ._build();

  _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate._(
      {required this.G__typename,
      required this.goal,
      required this.constraints,
      required this.guardrails})
      : super._();
  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate
      rebuild(
              void Function(
                      GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateBuilder
      toBuilder() =>
          GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate &&
        G__typename == other.G__typename &&
        goal == other.goal &&
        constraints == other.constraints &&
        guardrails == other.guardrails;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, goal.hashCode);
    _$hash = $jc(_$hash, constraints.hashCode);
    _$hash = $jc(_$hash, guardrails.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate')
          ..add('G__typename', G__typename)
          ..add('goal', goal)
          ..add('constraints', constraints)
          ..add('guardrails', guardrails))
        .toString();
  }
}

class GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateBuilder
    implements
        Builder<
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate,
            GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateBuilder> {
  _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate?
      _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _goal;
  String? get goal => _$this._goal;
  set goal(String? goal) => _$this._goal = goal;

  _i4.JsonObject? _constraints;
  _i4.JsonObject? get constraints => _$this._constraints;
  set constraints(_i4.JsonObject? constraints) =>
      _$this._constraints = constraints;

  _i4.JsonObject? _guardrails;
  _i4.JsonObject? get guardrails => _$this._guardrails;
  set guardrails(_i4.JsonObject? guardrails) => _$this._guardrails = guardrails;

  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateBuilder() {
    GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate
        ._initializeBuilder(this);
  }

  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _goal = $v.goal;
      _constraints = $v.constraints;
      _guardrails = $v.guardrails;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate
          other) {
    _$v = other
        as _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate;
  }

  @override
  void update(
      void Function(
              GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate
      build() => _build();

  _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate
      _build() {
    final _$result = _$v ??
        _$GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate
            ._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate',
              'G__typename'),
          goal: BuiltValueNullFieldError.checkNotNull(
              goal,
              r'GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate',
              'goal'),
          constraints: BuiltValueNullFieldError.checkNotNull(
              constraints,
              r'GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate',
              'constraints'),
          guardrails: BuiltValueNullFieldError.checkNotNull(
              guardrails,
              r'GPendingDecisionData_pendingDecision__asApprovalRequest_payload__asMandate',
              'guardrails'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
    extends GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation {
  @override
  final String G__typename;
  @override
  final String verdict;
  @override
  final String summary;
  @override
  final BuiltList<String> consideredFields;
  @override
  final String modelId;
  @override
  final String provider;
  @override
  final int tokensIn;
  @override
  final int tokensOut;
  @override
  final double estimatedCostUsd;
  @override
  final _i2.GTime at;

  factory _$GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation(
          [void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder)?
              updates]) =>
      (GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder()
            ..update(updates))
          ._build();

  _$GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation._(
      {required this.G__typename,
      required this.verdict,
      required this.summary,
      required this.consideredFields,
      required this.modelId,
      required this.provider,
      required this.tokensIn,
      required this.tokensOut,
      required this.estimatedCostUsd,
      required this.at})
      : super._();
  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
      rebuild(
              void Function(
                      GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder
      toBuilder() =>
          GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation &&
        G__typename == other.G__typename &&
        verdict == other.verdict &&
        summary == other.summary &&
        consideredFields == other.consideredFields &&
        modelId == other.modelId &&
        provider == other.provider &&
        tokensIn == other.tokensIn &&
        tokensOut == other.tokensOut &&
        estimatedCostUsd == other.estimatedCostUsd &&
        at == other.at;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, verdict.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, consideredFields.hashCode);
    _$hash = $jc(_$hash, modelId.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, tokensIn.hashCode);
    _$hash = $jc(_$hash, tokensOut.hashCode);
    _$hash = $jc(_$hash, estimatedCostUsd.hashCode);
    _$hash = $jc(_$hash, at.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation')
          ..add('G__typename', G__typename)
          ..add('verdict', verdict)
          ..add('summary', summary)
          ..add('consideredFields', consideredFields)
          ..add('modelId', modelId)
          ..add('provider', provider)
          ..add('tokensIn', tokensIn)
          ..add('tokensOut', tokensOut)
          ..add('estimatedCostUsd', estimatedCostUsd)
          ..add('at', at))
        .toString();
  }
}

class GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder
    implements
        Builder<
            GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation,
            GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder> {
  _$GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation?
      _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _verdict;
  String? get verdict => _$this._verdict;
  set verdict(String? verdict) => _$this._verdict = verdict;

  String? _summary;
  String? get summary => _$this._summary;
  set summary(String? summary) => _$this._summary = summary;

  ListBuilder<String>? _consideredFields;
  ListBuilder<String> get consideredFields =>
      _$this._consideredFields ??= ListBuilder<String>();
  set consideredFields(ListBuilder<String>? consideredFields) =>
      _$this._consideredFields = consideredFields;

  String? _modelId;
  String? get modelId => _$this._modelId;
  set modelId(String? modelId) => _$this._modelId = modelId;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  int? _tokensIn;
  int? get tokensIn => _$this._tokensIn;
  set tokensIn(int? tokensIn) => _$this._tokensIn = tokensIn;

  int? _tokensOut;
  int? get tokensOut => _$this._tokensOut;
  set tokensOut(int? tokensOut) => _$this._tokensOut = tokensOut;

  double? _estimatedCostUsd;
  double? get estimatedCostUsd => _$this._estimatedCostUsd;
  set estimatedCostUsd(double? estimatedCostUsd) =>
      _$this._estimatedCostUsd = estimatedCostUsd;

  _i2.GTimeBuilder? _at;
  _i2.GTimeBuilder get at => _$this._at ??= _i2.GTimeBuilder();
  set at(_i2.GTimeBuilder? at) => _$this._at = at;

  GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder() {
    GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
        ._initializeBuilder(this);
  }

  GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _verdict = $v.verdict;
      _summary = $v.summary;
      _consideredFields = $v.consideredFields.toBuilder();
      _modelId = $v.modelId;
      _provider = $v.provider;
      _tokensIn = $v.tokensIn;
      _tokensOut = $v.tokensOut;
      _estimatedCostUsd = $v.estimatedCostUsd;
      _at = $v.at.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
          other) {
    _$v = other
        as _$GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation;
  }

  @override
  void update(
      void Function(
              GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluationBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
      build() => _build();

  _$GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
      _build() {
    _$GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
        _$result;
    try {
      _$result = _$v ??
          _$GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation
              ._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation',
                'G__typename'),
            verdict: BuiltValueNullFieldError.checkNotNull(
                verdict,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation',
                'verdict'),
            summary: BuiltValueNullFieldError.checkNotNull(
                summary,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation',
                'summary'),
            consideredFields: consideredFields.build(),
            modelId: BuiltValueNullFieldError.checkNotNull(
                modelId,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation',
                'modelId'),
            provider: BuiltValueNullFieldError.checkNotNull(
                provider,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation',
                'provider'),
            tokensIn: BuiltValueNullFieldError.checkNotNull(
                tokensIn,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation',
                'tokensIn'),
            tokensOut: BuiltValueNullFieldError.checkNotNull(
                tokensOut,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation',
                'tokensOut'),
            estimatedCostUsd: BuiltValueNullFieldError.checkNotNull(
                estimatedCostUsd,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation',
                'estimatedCostUsd'),
            at: at.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'consideredFields';
        consideredFields.build();

        _$failedField = 'at';
        at.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GPendingDecisionData_pendingDecision__asApprovalRequest_overseerEvaluation',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
    extends GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation {
  @override
  final String G__typename;
  @override
  final String verdict;
  @override
  final String summary;
  @override
  final BuiltList<String> consideredFields;
  @override
  final BuiltList<String> hostcallTrace;
  @override
  final int scriptVersion;
  @override
  final _i2.GTime at;

  factory _$GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation(
          [void Function(
                  GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder)?
              updates]) =>
      (GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder()
            ..update(updates))
          ._build();

  _$GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation._(
      {required this.G__typename,
      required this.verdict,
      required this.summary,
      required this.consideredFields,
      required this.hostcallTrace,
      required this.scriptVersion,
      required this.at})
      : super._();
  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
      rebuild(
              void Function(
                      GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder
      toBuilder() =>
          GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation &&
        G__typename == other.G__typename &&
        verdict == other.verdict &&
        summary == other.summary &&
        consideredFields == other.consideredFields &&
        hostcallTrace == other.hostcallTrace &&
        scriptVersion == other.scriptVersion &&
        at == other.at;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, verdict.hashCode);
    _$hash = $jc(_$hash, summary.hashCode);
    _$hash = $jc(_$hash, consideredFields.hashCode);
    _$hash = $jc(_$hash, hostcallTrace.hashCode);
    _$hash = $jc(_$hash, scriptVersion.hashCode);
    _$hash = $jc(_$hash, at.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation')
          ..add('G__typename', G__typename)
          ..add('verdict', verdict)
          ..add('summary', summary)
          ..add('consideredFields', consideredFields)
          ..add('hostcallTrace', hostcallTrace)
          ..add('scriptVersion', scriptVersion)
          ..add('at', at))
        .toString();
  }
}

class GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder
    implements
        Builder<
            GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation,
            GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder> {
  _$GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation?
      _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _verdict;
  String? get verdict => _$this._verdict;
  set verdict(String? verdict) => _$this._verdict = verdict;

  String? _summary;
  String? get summary => _$this._summary;
  set summary(String? summary) => _$this._summary = summary;

  ListBuilder<String>? _consideredFields;
  ListBuilder<String> get consideredFields =>
      _$this._consideredFields ??= ListBuilder<String>();
  set consideredFields(ListBuilder<String>? consideredFields) =>
      _$this._consideredFields = consideredFields;

  ListBuilder<String>? _hostcallTrace;
  ListBuilder<String> get hostcallTrace =>
      _$this._hostcallTrace ??= ListBuilder<String>();
  set hostcallTrace(ListBuilder<String>? hostcallTrace) =>
      _$this._hostcallTrace = hostcallTrace;

  int? _scriptVersion;
  int? get scriptVersion => _$this._scriptVersion;
  set scriptVersion(int? scriptVersion) =>
      _$this._scriptVersion = scriptVersion;

  _i2.GTimeBuilder? _at;
  _i2.GTimeBuilder get at => _$this._at ??= _i2.GTimeBuilder();
  set at(_i2.GTimeBuilder? at) => _$this._at = at;

  GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder() {
    GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
        ._initializeBuilder(this);
  }

  GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _verdict = $v.verdict;
      _summary = $v.summary;
      _consideredFields = $v.consideredFields.toBuilder();
      _hostcallTrace = $v.hostcallTrace.toBuilder();
      _scriptVersion = $v.scriptVersion;
      _at = $v.at.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
          other) {
    _$v = other
        as _$GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation;
  }

  @override
  void update(
      void Function(
              GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluationBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
      build() => _build();

  _$GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
      _build() {
    _$GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
        _$result;
    try {
      _$result = _$v ??
          _$GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation
              ._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation',
                'G__typename'),
            verdict: BuiltValueNullFieldError.checkNotNull(
                verdict,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation',
                'verdict'),
            summary: BuiltValueNullFieldError.checkNotNull(
                summary,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation',
                'summary'),
            consideredFields: consideredFields.build(),
            hostcallTrace: hostcallTrace.build(),
            scriptVersion: BuiltValueNullFieldError.checkNotNull(
                scriptVersion,
                r'GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation',
                'scriptVersion'),
            at: at.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'consideredFields';
        consideredFields.build();
        _$failedField = 'hostcallTrace';
        hostcallTrace.build();

        _$failedField = 'at';
        at.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GPendingDecisionData_pendingDecision__asApprovalRequest_gateScriptEvaluation',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GPendingDecisionData_pendingDecision__asAgentQuestion
    extends GPendingDecisionData_pendingDecision__asAgentQuestion {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GTime createdAt;
  @override
  final GPendingDecisionData_pendingDecision__asAgentQuestion_asker asker;
  @override
  final String question;
  @override
  final String? disclosureClass;

  factory _$GPendingDecisionData_pendingDecision__asAgentQuestion(
          [void Function(
                  GPendingDecisionData_pendingDecision__asAgentQuestionBuilder)?
              updates]) =>
      (GPendingDecisionData_pendingDecision__asAgentQuestionBuilder()
            ..update(updates))
          ._build();

  _$GPendingDecisionData_pendingDecision__asAgentQuestion._(
      {required this.G__typename,
      required this.id,
      required this.createdAt,
      required this.asker,
      required this.question,
      this.disclosureClass})
      : super._();
  @override
  GPendingDecisionData_pendingDecision__asAgentQuestion rebuild(
          void Function(
                  GPendingDecisionData_pendingDecision__asAgentQuestionBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPendingDecisionData_pendingDecision__asAgentQuestionBuilder toBuilder() =>
      GPendingDecisionData_pendingDecision__asAgentQuestionBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GPendingDecisionData_pendingDecision__asAgentQuestion &&
        G__typename == other.G__typename &&
        id == other.id &&
        createdAt == other.createdAt &&
        asker == other.asker &&
        question == other.question &&
        disclosureClass == other.disclosureClass;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, asker.hashCode);
    _$hash = $jc(_$hash, question.hashCode);
    _$hash = $jc(_$hash, disclosureClass.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GPendingDecisionData_pendingDecision__asAgentQuestion')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('createdAt', createdAt)
          ..add('asker', asker)
          ..add('question', question)
          ..add('disclosureClass', disclosureClass))
        .toString();
  }
}

class GPendingDecisionData_pendingDecision__asAgentQuestionBuilder
    implements
        Builder<GPendingDecisionData_pendingDecision__asAgentQuestion,
            GPendingDecisionData_pendingDecision__asAgentQuestionBuilder> {
  _$GPendingDecisionData_pendingDecision__asAgentQuestion? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GTimeBuilder? _createdAt;
  _i2.GTimeBuilder get createdAt => _$this._createdAt ??= _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder? _asker;
  GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder
      get asker => _$this._asker ??=
          GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder();
  set asker(
          GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder?
              asker) =>
      _$this._asker = asker;

  String? _question;
  String? get question => _$this._question;
  set question(String? question) => _$this._question = question;

  String? _disclosureClass;
  String? get disclosureClass => _$this._disclosureClass;
  set disclosureClass(String? disclosureClass) =>
      _$this._disclosureClass = disclosureClass;

  GPendingDecisionData_pendingDecision__asAgentQuestionBuilder() {
    GPendingDecisionData_pendingDecision__asAgentQuestion._initializeBuilder(
        this);
  }

  GPendingDecisionData_pendingDecision__asAgentQuestionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _createdAt = $v.createdAt.toBuilder();
      _asker = $v.asker.toBuilder();
      _question = $v.question;
      _disclosureClass = $v.disclosureClass;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GPendingDecisionData_pendingDecision__asAgentQuestion other) {
    _$v = other as _$GPendingDecisionData_pendingDecision__asAgentQuestion;
  }

  @override
  void update(
      void Function(
              GPendingDecisionData_pendingDecision__asAgentQuestionBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GPendingDecisionData_pendingDecision__asAgentQuestion build() => _build();

  _$GPendingDecisionData_pendingDecision__asAgentQuestion _build() {
    _$GPendingDecisionData_pendingDecision__asAgentQuestion _$result;
    try {
      _$result = _$v ??
          _$GPendingDecisionData_pendingDecision__asAgentQuestion._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GPendingDecisionData_pendingDecision__asAgentQuestion',
                'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(id,
                r'GPendingDecisionData_pendingDecision__asAgentQuestion', 'id'),
            createdAt: createdAt.build(),
            asker: asker.build(),
            question: BuiltValueNullFieldError.checkNotNull(
                question,
                r'GPendingDecisionData_pendingDecision__asAgentQuestion',
                'question'),
            disclosureClass: disclosureClass,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
        _$failedField = 'asker';
        asker.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GPendingDecisionData_pendingDecision__asAgentQuestion',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GPendingDecisionData_pendingDecision__asAgentQuestion_asker
    extends GPendingDecisionData_pendingDecision__asAgentQuestion_asker {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String displayName;

  factory _$GPendingDecisionData_pendingDecision__asAgentQuestion_asker(
          [void Function(
                  GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder)?
              updates]) =>
      (GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder()
            ..update(updates))
          ._build();

  _$GPendingDecisionData_pendingDecision__asAgentQuestion_asker._(
      {required this.G__typename, required this.id, required this.displayName})
      : super._();
  @override
  GPendingDecisionData_pendingDecision__asAgentQuestion_asker rebuild(
          void Function(
                  GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder
      toBuilder() =>
          GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GPendingDecisionData_pendingDecision__asAgentQuestion_asker &&
        G__typename == other.G__typename &&
        id == other.id &&
        displayName == other.displayName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GPendingDecisionData_pendingDecision__asAgentQuestion_asker')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('displayName', displayName))
        .toString();
  }
}

class GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder
    implements
        Builder<GPendingDecisionData_pendingDecision__asAgentQuestion_asker,
            GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder> {
  _$GPendingDecisionData_pendingDecision__asAgentQuestion_asker? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder() {
    GPendingDecisionData_pendingDecision__asAgentQuestion_asker
        ._initializeBuilder(this);
  }

  GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _displayName = $v.displayName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GPendingDecisionData_pendingDecision__asAgentQuestion_asker other) {
    _$v =
        other as _$GPendingDecisionData_pendingDecision__asAgentQuestion_asker;
  }

  @override
  void update(
      void Function(
              GPendingDecisionData_pendingDecision__asAgentQuestion_askerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GPendingDecisionData_pendingDecision__asAgentQuestion_asker build() =>
      _build();

  _$GPendingDecisionData_pendingDecision__asAgentQuestion_asker _build() {
    final _$result = _$v ??
        _$GPendingDecisionData_pendingDecision__asAgentQuestion_asker._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GPendingDecisionData_pendingDecision__asAgentQuestion_asker',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GPendingDecisionData_pendingDecision__asAgentQuestion_asker',
              'id'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName,
              r'GPendingDecisionData_pendingDecision__asAgentQuestion_asker',
              'displayName'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GApproveArtifactData extends GApproveArtifactData {
  @override
  final String G__typename;
  @override
  final GApproveArtifactData_approveArtifact approveArtifact;

  factory _$GApproveArtifactData(
          [void Function(GApproveArtifactDataBuilder)? updates]) =>
      (GApproveArtifactDataBuilder()..update(updates))._build();

  _$GApproveArtifactData._(
      {required this.G__typename, required this.approveArtifact})
      : super._();
  @override
  GApproveArtifactData rebuild(
          void Function(GApproveArtifactDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GApproveArtifactDataBuilder toBuilder() =>
      GApproveArtifactDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GApproveArtifactData &&
        G__typename == other.G__typename &&
        approveArtifact == other.approveArtifact;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, approveArtifact.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GApproveArtifactData')
          ..add('G__typename', G__typename)
          ..add('approveArtifact', approveArtifact))
        .toString();
  }
}

class GApproveArtifactDataBuilder
    implements Builder<GApproveArtifactData, GApproveArtifactDataBuilder> {
  _$GApproveArtifactData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GApproveArtifactData_approveArtifactBuilder? _approveArtifact;
  GApproveArtifactData_approveArtifactBuilder get approveArtifact =>
      _$this._approveArtifact ??= GApproveArtifactData_approveArtifactBuilder();
  set approveArtifact(
          GApproveArtifactData_approveArtifactBuilder? approveArtifact) =>
      _$this._approveArtifact = approveArtifact;

  GApproveArtifactDataBuilder() {
    GApproveArtifactData._initializeBuilder(this);
  }

  GApproveArtifactDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _approveArtifact = $v.approveArtifact.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GApproveArtifactData other) {
    _$v = other as _$GApproveArtifactData;
  }

  @override
  void update(void Function(GApproveArtifactDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GApproveArtifactData build() => _build();

  _$GApproveArtifactData _build() {
    _$GApproveArtifactData _$result;
    try {
      _$result = _$v ??
          _$GApproveArtifactData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GApproveArtifactData', 'G__typename'),
            approveArtifact: approveArtifact.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'approveArtifact';
        approveArtifact.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GApproveArtifactData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GApproveArtifactData_approveArtifact
    extends GApproveArtifactData_approveArtifact {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GApproveArtifactData_approveArtifact(
          [void Function(GApproveArtifactData_approveArtifactBuilder)?
              updates]) =>
      (GApproveArtifactData_approveArtifactBuilder()..update(updates))._build();

  _$GApproveArtifactData_approveArtifact._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GApproveArtifactData_approveArtifact rebuild(
          void Function(GApproveArtifactData_approveArtifactBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GApproveArtifactData_approveArtifactBuilder toBuilder() =>
      GApproveArtifactData_approveArtifactBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GApproveArtifactData_approveArtifact &&
        G__typename == other.G__typename &&
        id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GApproveArtifactData_approveArtifact')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GApproveArtifactData_approveArtifactBuilder
    implements
        Builder<GApproveArtifactData_approveArtifact,
            GApproveArtifactData_approveArtifactBuilder> {
  _$GApproveArtifactData_approveArtifact? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GApproveArtifactData_approveArtifactBuilder() {
    GApproveArtifactData_approveArtifact._initializeBuilder(this);
  }

  GApproveArtifactData_approveArtifactBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GApproveArtifactData_approveArtifact other) {
    _$v = other as _$GApproveArtifactData_approveArtifact;
  }

  @override
  void update(
      void Function(GApproveArtifactData_approveArtifactBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GApproveArtifactData_approveArtifact build() => _build();

  _$GApproveArtifactData_approveArtifact _build() {
    final _$result = _$v ??
        _$GApproveArtifactData_approveArtifact._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GApproveArtifactData_approveArtifact', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GApproveArtifactData_approveArtifact', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GRejectApprovalData extends GRejectApprovalData {
  @override
  final String G__typename;
  @override
  final GRejectApprovalData_rejectApproval rejectApproval;

  factory _$GRejectApprovalData(
          [void Function(GRejectApprovalDataBuilder)? updates]) =>
      (GRejectApprovalDataBuilder()..update(updates))._build();

  _$GRejectApprovalData._(
      {required this.G__typename, required this.rejectApproval})
      : super._();
  @override
  GRejectApprovalData rebuild(
          void Function(GRejectApprovalDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRejectApprovalDataBuilder toBuilder() =>
      GRejectApprovalDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRejectApprovalData &&
        G__typename == other.G__typename &&
        rejectApproval == other.rejectApproval;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, rejectApproval.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRejectApprovalData')
          ..add('G__typename', G__typename)
          ..add('rejectApproval', rejectApproval))
        .toString();
  }
}

class GRejectApprovalDataBuilder
    implements Builder<GRejectApprovalData, GRejectApprovalDataBuilder> {
  _$GRejectApprovalData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GRejectApprovalData_rejectApprovalBuilder? _rejectApproval;
  GRejectApprovalData_rejectApprovalBuilder get rejectApproval =>
      _$this._rejectApproval ??= GRejectApprovalData_rejectApprovalBuilder();
  set rejectApproval(
          GRejectApprovalData_rejectApprovalBuilder? rejectApproval) =>
      _$this._rejectApproval = rejectApproval;

  GRejectApprovalDataBuilder() {
    GRejectApprovalData._initializeBuilder(this);
  }

  GRejectApprovalDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _rejectApproval = $v.rejectApproval.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRejectApprovalData other) {
    _$v = other as _$GRejectApprovalData;
  }

  @override
  void update(void Function(GRejectApprovalDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRejectApprovalData build() => _build();

  _$GRejectApprovalData _build() {
    _$GRejectApprovalData _$result;
    try {
      _$result = _$v ??
          _$GRejectApprovalData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GRejectApprovalData', 'G__typename'),
            rejectApproval: rejectApproval.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rejectApproval';
        rejectApproval.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GRejectApprovalData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GRejectApprovalData_rejectApproval
    extends GRejectApprovalData_rejectApproval {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GRejectApprovalData_rejectApproval(
          [void Function(GRejectApprovalData_rejectApprovalBuilder)?
              updates]) =>
      (GRejectApprovalData_rejectApprovalBuilder()..update(updates))._build();

  _$GRejectApprovalData_rejectApproval._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GRejectApprovalData_rejectApproval rebuild(
          void Function(GRejectApprovalData_rejectApprovalBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRejectApprovalData_rejectApprovalBuilder toBuilder() =>
      GRejectApprovalData_rejectApprovalBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRejectApprovalData_rejectApproval &&
        G__typename == other.G__typename &&
        id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRejectApprovalData_rejectApproval')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GRejectApprovalData_rejectApprovalBuilder
    implements
        Builder<GRejectApprovalData_rejectApproval,
            GRejectApprovalData_rejectApprovalBuilder> {
  _$GRejectApprovalData_rejectApproval? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GRejectApprovalData_rejectApprovalBuilder() {
    GRejectApprovalData_rejectApproval._initializeBuilder(this);
  }

  GRejectApprovalData_rejectApprovalBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRejectApprovalData_rejectApproval other) {
    _$v = other as _$GRejectApprovalData_rejectApproval;
  }

  @override
  void update(
      void Function(GRejectApprovalData_rejectApprovalBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRejectApprovalData_rejectApproval build() => _build();

  _$GRejectApprovalData_rejectApproval _build() {
    final _$result = _$v ??
        _$GRejectApprovalData_rejectApproval._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GRejectApprovalData_rejectApproval', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GRejectApprovalData_rejectApproval', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GAnswerQuestionData extends GAnswerQuestionData {
  @override
  final String G__typename;
  @override
  final GAnswerQuestionData_answerQuestion answerQuestion;

  factory _$GAnswerQuestionData(
          [void Function(GAnswerQuestionDataBuilder)? updates]) =>
      (GAnswerQuestionDataBuilder()..update(updates))._build();

  _$GAnswerQuestionData._(
      {required this.G__typename, required this.answerQuestion})
      : super._();
  @override
  GAnswerQuestionData rebuild(
          void Function(GAnswerQuestionDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAnswerQuestionDataBuilder toBuilder() =>
      GAnswerQuestionDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAnswerQuestionData &&
        G__typename == other.G__typename &&
        answerQuestion == other.answerQuestion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, answerQuestion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAnswerQuestionData')
          ..add('G__typename', G__typename)
          ..add('answerQuestion', answerQuestion))
        .toString();
  }
}

class GAnswerQuestionDataBuilder
    implements Builder<GAnswerQuestionData, GAnswerQuestionDataBuilder> {
  _$GAnswerQuestionData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GAnswerQuestionData_answerQuestionBuilder? _answerQuestion;
  GAnswerQuestionData_answerQuestionBuilder get answerQuestion =>
      _$this._answerQuestion ??= GAnswerQuestionData_answerQuestionBuilder();
  set answerQuestion(
          GAnswerQuestionData_answerQuestionBuilder? answerQuestion) =>
      _$this._answerQuestion = answerQuestion;

  GAnswerQuestionDataBuilder() {
    GAnswerQuestionData._initializeBuilder(this);
  }

  GAnswerQuestionDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _answerQuestion = $v.answerQuestion.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAnswerQuestionData other) {
    _$v = other as _$GAnswerQuestionData;
  }

  @override
  void update(void Function(GAnswerQuestionDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAnswerQuestionData build() => _build();

  _$GAnswerQuestionData _build() {
    _$GAnswerQuestionData _$result;
    try {
      _$result = _$v ??
          _$GAnswerQuestionData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GAnswerQuestionData', 'G__typename'),
            answerQuestion: answerQuestion.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'answerQuestion';
        answerQuestion.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GAnswerQuestionData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GAnswerQuestionData_answerQuestion
    extends GAnswerQuestionData_answerQuestion {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GAnswerQuestionData_answerQuestion(
          [void Function(GAnswerQuestionData_answerQuestionBuilder)?
              updates]) =>
      (GAnswerQuestionData_answerQuestionBuilder()..update(updates))._build();

  _$GAnswerQuestionData_answerQuestion._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GAnswerQuestionData_answerQuestion rebuild(
          void Function(GAnswerQuestionData_answerQuestionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAnswerQuestionData_answerQuestionBuilder toBuilder() =>
      GAnswerQuestionData_answerQuestionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAnswerQuestionData_answerQuestion &&
        G__typename == other.G__typename &&
        id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAnswerQuestionData_answerQuestion')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GAnswerQuestionData_answerQuestionBuilder
    implements
        Builder<GAnswerQuestionData_answerQuestion,
            GAnswerQuestionData_answerQuestionBuilder> {
  _$GAnswerQuestionData_answerQuestion? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GAnswerQuestionData_answerQuestionBuilder() {
    GAnswerQuestionData_answerQuestion._initializeBuilder(this);
  }

  GAnswerQuestionData_answerQuestionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAnswerQuestionData_answerQuestion other) {
    _$v = other as _$GAnswerQuestionData_answerQuestion;
  }

  @override
  void update(
      void Function(GAnswerQuestionData_answerQuestionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAnswerQuestionData_answerQuestion build() => _build();

  _$GAnswerQuestionData_answerQuestion _build() {
    final _$result = _$v ??
        _$GAnswerQuestionData_answerQuestion._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GAnswerQuestionData_answerQuestion', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GAnswerQuestionData_answerQuestion', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
