// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i2;

part 'update_task_metadata.var.gql.g.dart';

abstract class GUpdateTaskMetadataVars
    implements Built<GUpdateTaskMetadataVars, GUpdateTaskMetadataVarsBuilder> {
  GUpdateTaskMetadataVars._();

  factory GUpdateTaskMetadataVars(
          [void Function(GUpdateTaskMetadataVarsBuilder b) updates]) =
      _$GUpdateTaskMetadataVars;

  String get taskId;
  _i1.GTaskPriority get priority;
  _i1.GTime? get dueAt;
  _i1.GTime? get startsAt;
  double? get rank;
  static Serializer<GUpdateTaskMetadataVars> get serializer =>
      _$gUpdateTaskMetadataVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GUpdateTaskMetadataVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateTaskMetadataVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GUpdateTaskMetadataVars.serializer,
        json,
      );
}
