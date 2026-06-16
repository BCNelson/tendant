// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i2;

part 'create_task.var.gql.g.dart';

abstract class GCreateTaskVars
    implements Built<GCreateTaskVars, GCreateTaskVarsBuilder> {
  GCreateTaskVars._();

  factory GCreateTaskVars([void Function(GCreateTaskVarsBuilder b) updates]) =
      _$GCreateTaskVars;

  String get title;
  String? get description;
  _i1.GTaskPriority? get priority;
  _i1.GTime? get dueAt;
  _i1.GTime? get startsAt;
  double? get rank;
  static Serializer<GCreateTaskVars> get serializer =>
      _$gCreateTaskVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GCreateTaskVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateTaskVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GCreateTaskVars.serializer,
        json,
      );
}
