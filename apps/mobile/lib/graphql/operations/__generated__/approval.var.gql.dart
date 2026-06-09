// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'approval.var.gql.g.dart';

abstract class GPendingDecisionVars
    implements Built<GPendingDecisionVars, GPendingDecisionVarsBuilder> {
  GPendingDecisionVars._();

  factory GPendingDecisionVars(
          [void Function(GPendingDecisionVarsBuilder b) updates]) =
      _$GPendingDecisionVars;

  String get id;
  static Serializer<GPendingDecisionVars> get serializer =>
      _$gPendingDecisionVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPendingDecisionVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPendingDecisionVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPendingDecisionVars.serializer,
        json,
      );
}

abstract class GApproveArtifactVars
    implements Built<GApproveArtifactVars, GApproveArtifactVarsBuilder> {
  GApproveArtifactVars._();

  factory GApproveArtifactVars(
          [void Function(GApproveArtifactVarsBuilder b) updates]) =
      _$GApproveArtifactVars;

  String get decisionId;
  static Serializer<GApproveArtifactVars> get serializer =>
      _$gApproveArtifactVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GApproveArtifactVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GApproveArtifactVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GApproveArtifactVars.serializer,
        json,
      );
}

abstract class GRejectApprovalVars
    implements Built<GRejectApprovalVars, GRejectApprovalVarsBuilder> {
  GRejectApprovalVars._();

  factory GRejectApprovalVars(
          [void Function(GRejectApprovalVarsBuilder b) updates]) =
      _$GRejectApprovalVars;

  String get decisionId;
  String? get reason;
  static Serializer<GRejectApprovalVars> get serializer =>
      _$gRejectApprovalVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRejectApprovalVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRejectApprovalVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRejectApprovalVars.serializer,
        json,
      );
}

abstract class GAnswerQuestionVars
    implements Built<GAnswerQuestionVars, GAnswerQuestionVarsBuilder> {
  GAnswerQuestionVars._();

  factory GAnswerQuestionVars(
          [void Function(GAnswerQuestionVarsBuilder b) updates]) =
      _$GAnswerQuestionVars;

  String get decisionId;
  String get answer;
  static Serializer<GAnswerQuestionVars> get serializer =>
      _$gAnswerQuestionVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAnswerQuestionVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAnswerQuestionVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAnswerQuestionVars.serializer,
        json,
      );
}
