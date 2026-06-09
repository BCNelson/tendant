// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'agent_assignment.var.gql.g.dart';

abstract class GAgentAssignmentVars
    implements Built<GAgentAssignmentVars, GAgentAssignmentVarsBuilder> {
  GAgentAssignmentVars._();

  factory GAgentAssignmentVars(
          [void Function(GAgentAssignmentVarsBuilder b) updates]) =
      _$GAgentAssignmentVars;

  String get id;
  static Serializer<GAgentAssignmentVars> get serializer =>
      _$gAgentAssignmentVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAgentAssignmentVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAgentAssignmentVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAgentAssignmentVars.serializer,
        json,
      );
}
