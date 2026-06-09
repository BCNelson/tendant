// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'config.data.gql.g.dart';

abstract class GConfigKeysData
    implements Built<GConfigKeysData, GConfigKeysDataBuilder> {
  GConfigKeysData._();

  factory GConfigKeysData([void Function(GConfigKeysDataBuilder b) updates]) =
      _$GConfigKeysData;

  static void _initializeBuilder(GConfigKeysDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  BuiltList<GConfigKeysData_configKeys> get configKeys;
  static Serializer<GConfigKeysData> get serializer =>
      _$gConfigKeysDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GConfigKeysData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GConfigKeysData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GConfigKeysData.serializer,
        json,
      );
}

abstract class GConfigKeysData_configKeys
    implements
        Built<GConfigKeysData_configKeys, GConfigKeysData_configKeysBuilder> {
  GConfigKeysData_configKeys._();

  factory GConfigKeysData_configKeys(
          [void Function(GConfigKeysData_configKeysBuilder b) updates]) =
      _$GConfigKeysData_configKeys;

  static void _initializeBuilder(GConfigKeysData_configKeysBuilder b) =>
      b..G__typename = 'ConfigKey';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get key;
  String get type;
  String get description;
  String get reload;
  bool get sensitive;
  bool get dbConfigurable;
  bool get hotReloadable;
  String? get readonlyReason;
  String? get defaultValue;
  String? get effectiveValue;
  bool get overridden;
  static Serializer<GConfigKeysData_configKeys> get serializer =>
      _$gConfigKeysDataConfigKeysSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GConfigKeysData_configKeys.serializer,
        this,
      ) as Map<String, dynamic>);

  static GConfigKeysData_configKeys? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GConfigKeysData_configKeys.serializer,
        json,
      );
}

abstract class GSetConfigEntryData
    implements Built<GSetConfigEntryData, GSetConfigEntryDataBuilder> {
  GSetConfigEntryData._();

  factory GSetConfigEntryData(
          [void Function(GSetConfigEntryDataBuilder b) updates]) =
      _$GSetConfigEntryData;

  static void _initializeBuilder(GSetConfigEntryDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GSetConfigEntryData_setConfigEntry get setConfigEntry;
  static Serializer<GSetConfigEntryData> get serializer =>
      _$gSetConfigEntryDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSetConfigEntryData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSetConfigEntryData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSetConfigEntryData.serializer,
        json,
      );
}

abstract class GSetConfigEntryData_setConfigEntry
    implements
        Built<GSetConfigEntryData_setConfigEntry,
            GSetConfigEntryData_setConfigEntryBuilder> {
  GSetConfigEntryData_setConfigEntry._();

  factory GSetConfigEntryData_setConfigEntry(
      [void Function(GSetConfigEntryData_setConfigEntryBuilder b)
          updates]) = _$GSetConfigEntryData_setConfigEntry;

  static void _initializeBuilder(GSetConfigEntryData_setConfigEntryBuilder b) =>
      b..G__typename = 'ConfigKey';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get key;
  String? get effectiveValue;
  bool get overridden;
  static Serializer<GSetConfigEntryData_setConfigEntry> get serializer =>
      _$gSetConfigEntryDataSetConfigEntrySerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSetConfigEntryData_setConfigEntry.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSetConfigEntryData_setConfigEntry? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSetConfigEntryData_setConfigEntry.serializer,
        json,
      );
}

abstract class GDeleteConfigEntryData
    implements Built<GDeleteConfigEntryData, GDeleteConfigEntryDataBuilder> {
  GDeleteConfigEntryData._();

  factory GDeleteConfigEntryData(
          [void Function(GDeleteConfigEntryDataBuilder b) updates]) =
      _$GDeleteConfigEntryData;

  static void _initializeBuilder(GDeleteConfigEntryDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get deleteConfigEntry;
  static Serializer<GDeleteConfigEntryData> get serializer =>
      _$gDeleteConfigEntryDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDeleteConfigEntryData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeleteConfigEntryData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDeleteConfigEntryData.serializer,
        json,
      );
}
