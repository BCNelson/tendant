// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'proposed_task.data.gql.g.dart';

abstract class GAcceptProposedTaskData
    implements Built<GAcceptProposedTaskData, GAcceptProposedTaskDataBuilder> {
  GAcceptProposedTaskData._();

  factory GAcceptProposedTaskData(
          [void Function(GAcceptProposedTaskDataBuilder b) updates]) =
      _$GAcceptProposedTaskData;

  static void _initializeBuilder(GAcceptProposedTaskDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GAcceptProposedTaskData_acceptProposedTask get acceptProposedTask;
  static Serializer<GAcceptProposedTaskData> get serializer =>
      _$gAcceptProposedTaskDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAcceptProposedTaskData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAcceptProposedTaskData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAcceptProposedTaskData.serializer,
        json,
      );
}

abstract class GAcceptProposedTaskData_acceptProposedTask
    implements
        Built<GAcceptProposedTaskData_acceptProposedTask,
            GAcceptProposedTaskData_acceptProposedTaskBuilder> {
  GAcceptProposedTaskData_acceptProposedTask._();

  factory GAcceptProposedTaskData_acceptProposedTask(
      [void Function(GAcceptProposedTaskData_acceptProposedTaskBuilder b)
          updates]) = _$GAcceptProposedTaskData_acceptProposedTask;

  static void _initializeBuilder(
          GAcceptProposedTaskData_acceptProposedTaskBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GTaskState get state;
  static Serializer<GAcceptProposedTaskData_acceptProposedTask>
      get serializer => _$gAcceptProposedTaskDataAcceptProposedTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAcceptProposedTaskData_acceptProposedTask.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAcceptProposedTaskData_acceptProposedTask? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAcceptProposedTaskData_acceptProposedTask.serializer,
        json,
      );
}

abstract class GDismissProposedTaskData
    implements
        Built<GDismissProposedTaskData, GDismissProposedTaskDataBuilder> {
  GDismissProposedTaskData._();

  factory GDismissProposedTaskData(
          [void Function(GDismissProposedTaskDataBuilder b) updates]) =
      _$GDismissProposedTaskData;

  static void _initializeBuilder(GDismissProposedTaskDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GDismissProposedTaskData_dismissProposedTask get dismissProposedTask;
  static Serializer<GDismissProposedTaskData> get serializer =>
      _$gDismissProposedTaskDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDismissProposedTaskData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDismissProposedTaskData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDismissProposedTaskData.serializer,
        json,
      );
}

abstract class GDismissProposedTaskData_dismissProposedTask
    implements
        Built<GDismissProposedTaskData_dismissProposedTask,
            GDismissProposedTaskData_dismissProposedTaskBuilder> {
  GDismissProposedTaskData_dismissProposedTask._();

  factory GDismissProposedTaskData_dismissProposedTask(
      [void Function(GDismissProposedTaskData_dismissProposedTaskBuilder b)
          updates]) = _$GDismissProposedTaskData_dismissProposedTask;

  static void _initializeBuilder(
          GDismissProposedTaskData_dismissProposedTaskBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GTaskState get state;
  static Serializer<GDismissProposedTaskData_dismissProposedTask>
      get serializer => _$gDismissProposedTaskDataDismissProposedTaskSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDismissProposedTaskData_dismissProposedTask.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDismissProposedTaskData_dismissProposedTask? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDismissProposedTaskData_dismissProposedTask.serializer,
        json,
      );
}
