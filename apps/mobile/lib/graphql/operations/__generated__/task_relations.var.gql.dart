// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i2;

part 'task_relations.var.gql.g.dart';

abstract class GAddTaskRelationVars
    implements Built<GAddTaskRelationVars, GAddTaskRelationVarsBuilder> {
  GAddTaskRelationVars._();

  factory GAddTaskRelationVars(
          [void Function(GAddTaskRelationVarsBuilder b) updates]) =
      _$GAddTaskRelationVars;

  String get fromTaskId;
  String get toTaskId;
  _i1.GTaskRelationKind get kind;
  static Serializer<GAddTaskRelationVars> get serializer =>
      _$gAddTaskRelationVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GAddTaskRelationVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAddTaskRelationVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GAddTaskRelationVars.serializer,
        json,
      );
}

abstract class GRemoveTaskRelationVars
    implements Built<GRemoveTaskRelationVars, GRemoveTaskRelationVarsBuilder> {
  GRemoveTaskRelationVars._();

  factory GRemoveTaskRelationVars(
          [void Function(GRemoveTaskRelationVarsBuilder b) updates]) =
      _$GRemoveTaskRelationVars;

  String get fromTaskId;
  String get toTaskId;
  _i1.GTaskRelationKind get kind;
  static Serializer<GRemoveTaskRelationVars> get serializer =>
      _$gRemoveTaskRelationVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GRemoveTaskRelationVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRemoveTaskRelationVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GRemoveTaskRelationVars.serializer,
        json,
      );
}
