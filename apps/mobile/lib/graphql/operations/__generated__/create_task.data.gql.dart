// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'create_task.data.gql.g.dart';

abstract class GCreateTaskData
    implements Built<GCreateTaskData, GCreateTaskDataBuilder> {
  GCreateTaskData._();

  factory GCreateTaskData([void Function(GCreateTaskDataBuilder b) updates]) =
      _$GCreateTaskData;

  static void _initializeBuilder(GCreateTaskDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GCreateTaskData_createTask get createTask;
  static Serializer<GCreateTaskData> get serializer =>
      _$gCreateTaskDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCreateTaskData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateTaskData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCreateTaskData.serializer,
        json,
      );
}

abstract class GCreateTaskData_createTask
    implements
        Built<GCreateTaskData_createTask, GCreateTaskData_createTaskBuilder> {
  GCreateTaskData_createTask._();

  factory GCreateTaskData_createTask(
          [void Function(GCreateTaskData_createTaskBuilder b) updates]) =
      _$GCreateTaskData_createTask;

  static void _initializeBuilder(GCreateTaskData_createTaskBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  int get shortId;
  String get title;
  _i2.GTaskState get state;
  static Serializer<GCreateTaskData_createTask> get serializer =>
      _$gCreateTaskDataCreateTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCreateTaskData_createTask.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateTaskData_createTask? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCreateTaskData_createTask.serializer,
        json,
      );
}
