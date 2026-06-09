// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'task_changed_subscription.data.gql.g.dart';

abstract class GTaskChangedData
    implements Built<GTaskChangedData, GTaskChangedDataBuilder> {
  GTaskChangedData._();

  factory GTaskChangedData([void Function(GTaskChangedDataBuilder b) updates]) =
      _$GTaskChangedData;

  static void _initializeBuilder(GTaskChangedDataBuilder b) =>
      b..G__typename = 'Subscription';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GTaskChangedData_taskChanged get taskChanged;
  static Serializer<GTaskChangedData> get serializer =>
      _$gTaskChangedDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskChangedData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskChangedData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskChangedData.serializer,
        json,
      );
}

abstract class GTaskChangedData_taskChanged
    implements
        Built<GTaskChangedData_taskChanged,
            GTaskChangedData_taskChangedBuilder> {
  GTaskChangedData_taskChanged._();

  factory GTaskChangedData_taskChanged(
          [void Function(GTaskChangedData_taskChangedBuilder b) updates]) =
      _$GTaskChangedData_taskChanged;

  static void _initializeBuilder(GTaskChangedData_taskChangedBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GTaskState get state;
  _i2.GChainStage get currentStage;
  static Serializer<GTaskChangedData_taskChanged> get serializer =>
      _$gTaskChangedDataTaskChangedSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskChangedData_taskChanged.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskChangedData_taskChanged? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskChangedData_taskChanged.serializer,
        json,
      );
}
