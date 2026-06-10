// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'update_task_metadata.data.gql.g.dart';

abstract class GUpdateTaskMetadataData
    implements Built<GUpdateTaskMetadataData, GUpdateTaskMetadataDataBuilder> {
  GUpdateTaskMetadataData._();

  factory GUpdateTaskMetadataData(
          [void Function(GUpdateTaskMetadataDataBuilder b) updates]) =
      _$GUpdateTaskMetadataData;

  static void _initializeBuilder(GUpdateTaskMetadataDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GUpdateTaskMetadataData_updateTaskMetadata get updateTaskMetadata;
  static Serializer<GUpdateTaskMetadataData> get serializer =>
      _$gUpdateTaskMetadataDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUpdateTaskMetadataData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateTaskMetadataData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GUpdateTaskMetadataData.serializer,
        json,
      );
}

abstract class GUpdateTaskMetadataData_updateTaskMetadata
    implements
        Built<GUpdateTaskMetadataData_updateTaskMetadata,
            GUpdateTaskMetadataData_updateTaskMetadataBuilder> {
  GUpdateTaskMetadataData_updateTaskMetadata._();

  factory GUpdateTaskMetadataData_updateTaskMetadata(
      [void Function(GUpdateTaskMetadataData_updateTaskMetadataBuilder b)
          updates]) = _$GUpdateTaskMetadataData_updateTaskMetadata;

  static void _initializeBuilder(
          GUpdateTaskMetadataData_updateTaskMetadataBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GTaskPriority get priority;
  _i2.GTime? get dueAt;
  static Serializer<GUpdateTaskMetadataData_updateTaskMetadata>
      get serializer => _$gUpdateTaskMetadataDataUpdateTaskMetadataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUpdateTaskMetadataData_updateTaskMetadata.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateTaskMetadataData_updateTaskMetadata? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GUpdateTaskMetadataData_updateTaskMetadata.serializer,
        json,
      );
}
