// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart' as _i1;
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i2;

part 'complete_task.var.gql.g.dart';

abstract class GCompleteTaskVars
    implements Built<GCompleteTaskVars, GCompleteTaskVarsBuilder> {
  GCompleteTaskVars._();

  factory GCompleteTaskVars(
          [void Function(GCompleteTaskVarsBuilder b) updates]) =
      _$GCompleteTaskVars;

  String get taskId;
  _i1.JsonObject? get result;
  static Serializer<GCompleteTaskVars> get serializer =>
      _$gCompleteTaskVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GCompleteTaskVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCompleteTaskVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GCompleteTaskVars.serializer,
        json,
      );
}
