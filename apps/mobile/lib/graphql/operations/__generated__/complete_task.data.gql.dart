// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'complete_task.data.gql.g.dart';

abstract class GCompleteTaskData
    implements Built<GCompleteTaskData, GCompleteTaskDataBuilder> {
  GCompleteTaskData._();

  factory GCompleteTaskData(
          [void Function(GCompleteTaskDataBuilder b) updates]) =
      _$GCompleteTaskData;

  static void _initializeBuilder(GCompleteTaskDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GCompleteTaskData_completeTask get completeTask;
  static Serializer<GCompleteTaskData> get serializer =>
      _$gCompleteTaskDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCompleteTaskData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCompleteTaskData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCompleteTaskData.serializer,
        json,
      );
}

abstract class GCompleteTaskData_completeTask
    implements
        Built<GCompleteTaskData_completeTask,
            GCompleteTaskData_completeTaskBuilder> {
  GCompleteTaskData_completeTask._();

  factory GCompleteTaskData_completeTask(
          [void Function(GCompleteTaskData_completeTaskBuilder b) updates]) =
      _$GCompleteTaskData_completeTask;

  static void _initializeBuilder(GCompleteTaskData_completeTaskBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GTaskState get state;
  _i2.GChainStage get currentStage;
  static Serializer<GCompleteTaskData_completeTask> get serializer =>
      _$gCompleteTaskDataCompleteTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCompleteTaskData_completeTask.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCompleteTaskData_completeTask? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCompleteTaskData_completeTask.serializer,
        json,
      );
}
