// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'routing.var.gql.g.dart';

abstract class GTaskStageSlotsVars
    implements Built<GTaskStageSlotsVars, GTaskStageSlotsVarsBuilder> {
  GTaskStageSlotsVars._();

  factory GTaskStageSlotsVars(
          [void Function(GTaskStageSlotsVarsBuilder b) updates]) =
      _$GTaskStageSlotsVars;

  String get taskId;
  static Serializer<GTaskStageSlotsVars> get serializer =>
      _$gTaskStageSlotsVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskStageSlotsVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskStageSlotsVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskStageSlotsVars.serializer,
        json,
      );
}

abstract class GAgentConfigsVars
    implements Built<GAgentConfigsVars, GAgentConfigsVarsBuilder> {
  GAgentConfigsVars._();

  factory GAgentConfigsVars(
          [void Function(GAgentConfigsVarsBuilder b) updates]) =
      _$GAgentConfigsVars;

  _i2.GAgentStage? get stage;
  static Serializer<GAgentConfigsVars> get serializer =>
      _$gAgentConfigsVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAgentConfigsVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAgentConfigsVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAgentConfigsVars.serializer,
        json,
      );
}
