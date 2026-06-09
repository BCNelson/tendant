// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'feedback.var.gql.g.dart';

abstract class GFeedbackRequestVars
    implements Built<GFeedbackRequestVars, GFeedbackRequestVarsBuilder> {
  GFeedbackRequestVars._();

  factory GFeedbackRequestVars(
          [void Function(GFeedbackRequestVarsBuilder b) updates]) =
      _$GFeedbackRequestVars;

  String get id;
  static Serializer<GFeedbackRequestVars> get serializer =>
      _$gFeedbackRequestVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GFeedbackRequestVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GFeedbackRequestVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GFeedbackRequestVars.serializer,
        json,
      );
}

abstract class GSendFeedbackMessageVars
    implements
        Built<GSendFeedbackMessageVars, GSendFeedbackMessageVarsBuilder> {
  GSendFeedbackMessageVars._();

  factory GSendFeedbackMessageVars(
          [void Function(GSendFeedbackMessageVarsBuilder b) updates]) =
      _$GSendFeedbackMessageVars;

  String get decisionId;
  String get text;
  static Serializer<GSendFeedbackMessageVars> get serializer =>
      _$gSendFeedbackMessageVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSendFeedbackMessageVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendFeedbackMessageVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSendFeedbackMessageVars.serializer,
        json,
      );
}

abstract class GAcceptFeedbackGuidanceVars
    implements
        Built<GAcceptFeedbackGuidanceVars, GAcceptFeedbackGuidanceVarsBuilder> {
  GAcceptFeedbackGuidanceVars._();

  factory GAcceptFeedbackGuidanceVars(
          [void Function(GAcceptFeedbackGuidanceVarsBuilder b) updates]) =
      _$GAcceptFeedbackGuidanceVars;

  String get decisionId;
  String get guidance;
  _i2.GGuidanceScope get scope;
  String? get agentConfigId;
  int? get rating;
  static Serializer<GAcceptFeedbackGuidanceVars> get serializer =>
      _$gAcceptFeedbackGuidanceVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAcceptFeedbackGuidanceVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAcceptFeedbackGuidanceVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAcceptFeedbackGuidanceVars.serializer,
        json,
      );
}

abstract class GDismissFeedbackVars
    implements Built<GDismissFeedbackVars, GDismissFeedbackVarsBuilder> {
  GDismissFeedbackVars._();

  factory GDismissFeedbackVars(
          [void Function(GDismissFeedbackVarsBuilder b) updates]) =
      _$GDismissFeedbackVars;

  String get decisionId;
  int? get rating;
  static Serializer<GDismissFeedbackVars> get serializer =>
      _$gDismissFeedbackVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDismissFeedbackVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDismissFeedbackVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDismissFeedbackVars.serializer,
        json,
      );
}
