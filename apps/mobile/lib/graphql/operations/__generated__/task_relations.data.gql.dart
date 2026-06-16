// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'task_relations.data.gql.g.dart';

abstract class GAddTaskRelationData
    implements Built<GAddTaskRelationData, GAddTaskRelationDataBuilder> {
  GAddTaskRelationData._();

  factory GAddTaskRelationData(
          [void Function(GAddTaskRelationDataBuilder b) updates]) =
      _$GAddTaskRelationData;

  static void _initializeBuilder(GAddTaskRelationDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GAddTaskRelationData_addTaskRelation get addTaskRelation;
  static Serializer<GAddTaskRelationData> get serializer =>
      _$gAddTaskRelationDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAddTaskRelationData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAddTaskRelationData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAddTaskRelationData.serializer,
        json,
      );
}

abstract class GAddTaskRelationData_addTaskRelation
    implements
        Built<GAddTaskRelationData_addTaskRelation,
            GAddTaskRelationData_addTaskRelationBuilder> {
  GAddTaskRelationData_addTaskRelation._();

  factory GAddTaskRelationData_addTaskRelation(
      [void Function(GAddTaskRelationData_addTaskRelationBuilder b)
          updates]) = _$GAddTaskRelationData_addTaskRelation;

  static void _initializeBuilder(
          GAddTaskRelationData_addTaskRelationBuilder b) =>
      b..G__typename = 'TaskRelation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GTaskRelationKind get kind;
  GAddTaskRelationData_addTaskRelation_from get from;
  GAddTaskRelationData_addTaskRelation_to get to;
  static Serializer<GAddTaskRelationData_addTaskRelation> get serializer =>
      _$gAddTaskRelationDataAddTaskRelationSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAddTaskRelationData_addTaskRelation.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAddTaskRelationData_addTaskRelation? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAddTaskRelationData_addTaskRelation.serializer,
        json,
      );
}

abstract class GAddTaskRelationData_addTaskRelation_from
    implements
        Built<GAddTaskRelationData_addTaskRelation_from,
            GAddTaskRelationData_addTaskRelation_fromBuilder> {
  GAddTaskRelationData_addTaskRelation_from._();

  factory GAddTaskRelationData_addTaskRelation_from(
      [void Function(GAddTaskRelationData_addTaskRelation_fromBuilder b)
          updates]) = _$GAddTaskRelationData_addTaskRelation_from;

  static void _initializeBuilder(
          GAddTaskRelationData_addTaskRelation_fromBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GAddTaskRelationData_addTaskRelation_from> get serializer =>
      _$gAddTaskRelationDataAddTaskRelationFromSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAddTaskRelationData_addTaskRelation_from.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAddTaskRelationData_addTaskRelation_from? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAddTaskRelationData_addTaskRelation_from.serializer,
        json,
      );
}

abstract class GAddTaskRelationData_addTaskRelation_to
    implements
        Built<GAddTaskRelationData_addTaskRelation_to,
            GAddTaskRelationData_addTaskRelation_toBuilder> {
  GAddTaskRelationData_addTaskRelation_to._();

  factory GAddTaskRelationData_addTaskRelation_to(
      [void Function(GAddTaskRelationData_addTaskRelation_toBuilder b)
          updates]) = _$GAddTaskRelationData_addTaskRelation_to;

  static void _initializeBuilder(
          GAddTaskRelationData_addTaskRelation_toBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GAddTaskRelationData_addTaskRelation_to> get serializer =>
      _$gAddTaskRelationDataAddTaskRelationToSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAddTaskRelationData_addTaskRelation_to.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAddTaskRelationData_addTaskRelation_to? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAddTaskRelationData_addTaskRelation_to.serializer,
        json,
      );
}

abstract class GRemoveTaskRelationData
    implements Built<GRemoveTaskRelationData, GRemoveTaskRelationDataBuilder> {
  GRemoveTaskRelationData._();

  factory GRemoveTaskRelationData(
          [void Function(GRemoveTaskRelationDataBuilder b) updates]) =
      _$GRemoveTaskRelationData;

  static void _initializeBuilder(GRemoveTaskRelationDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get removeTaskRelation;
  static Serializer<GRemoveTaskRelationData> get serializer =>
      _$gRemoveTaskRelationDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRemoveTaskRelationData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRemoveTaskRelationData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRemoveTaskRelationData.serializer,
        json,
      );
}
