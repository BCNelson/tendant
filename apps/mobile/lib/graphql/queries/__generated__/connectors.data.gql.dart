// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart' as _i2;
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'connectors.data.gql.g.dart';

abstract class GConnectorsData
    implements Built<GConnectorsData, GConnectorsDataBuilder> {
  GConnectorsData._();

  factory GConnectorsData([void Function(GConnectorsDataBuilder b) updates]) =
      _$GConnectorsData;

  static void _initializeBuilder(GConnectorsDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  BuiltList<GConnectorsData_connectors> get connectors;
  static Serializer<GConnectorsData> get serializer =>
      _$gConnectorsDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GConnectorsData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GConnectorsData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GConnectorsData.serializer,
        json,
      );
}

abstract class GConnectorsData_connectors
    implements
        Built<GConnectorsData_connectors, GConnectorsData_connectorsBuilder> {
  GConnectorsData_connectors._();

  factory GConnectorsData_connectors(
          [void Function(GConnectorsData_connectorsBuilder b) updates]) =
      _$GConnectorsData_connectors;

  static void _initializeBuilder(GConnectorsData_connectorsBuilder b) =>
      b..G__typename = 'Connector';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get connectorType;
  bool get enabled;
  _i2.JsonObject get config;
  static Serializer<GConnectorsData_connectors> get serializer =>
      _$gConnectorsDataConnectorsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GConnectorsData_connectors.serializer,
        this,
      ) as Map<String, dynamic>);

  static GConnectorsData_connectors? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GConnectorsData_connectors.serializer,
        json,
      );
}

abstract class GSetConnectorConfigData
    implements Built<GSetConnectorConfigData, GSetConnectorConfigDataBuilder> {
  GSetConnectorConfigData._();

  factory GSetConnectorConfigData(
          [void Function(GSetConnectorConfigDataBuilder b) updates]) =
      _$GSetConnectorConfigData;

  static void _initializeBuilder(GSetConnectorConfigDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GSetConnectorConfigData_setConnectorConfig get setConnectorConfig;
  static Serializer<GSetConnectorConfigData> get serializer =>
      _$gSetConnectorConfigDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSetConnectorConfigData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSetConnectorConfigData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSetConnectorConfigData.serializer,
        json,
      );
}

abstract class GSetConnectorConfigData_setConnectorConfig
    implements
        Built<GSetConnectorConfigData_setConnectorConfig,
            GSetConnectorConfigData_setConnectorConfigBuilder> {
  GSetConnectorConfigData_setConnectorConfig._();

  factory GSetConnectorConfigData_setConnectorConfig(
      [void Function(GSetConnectorConfigData_setConnectorConfigBuilder b)
          updates]) = _$GSetConnectorConfigData_setConnectorConfig;

  static void _initializeBuilder(
          GSetConnectorConfigData_setConnectorConfigBuilder b) =>
      b..G__typename = 'Connector';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get connectorType;
  bool get enabled;
  _i2.JsonObject get config;
  static Serializer<GSetConnectorConfigData_setConnectorConfig>
      get serializer => _$gSetConnectorConfigDataSetConnectorConfigSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSetConnectorConfigData_setConnectorConfig.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSetConnectorConfigData_setConnectorConfig? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSetConnectorConfigData_setConnectorConfig.serializer,
        json,
      );
}

abstract class GEnableConnectorData
    implements Built<GEnableConnectorData, GEnableConnectorDataBuilder> {
  GEnableConnectorData._();

  factory GEnableConnectorData(
          [void Function(GEnableConnectorDataBuilder b) updates]) =
      _$GEnableConnectorData;

  static void _initializeBuilder(GEnableConnectorDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GEnableConnectorData_enableConnector get enableConnector;
  static Serializer<GEnableConnectorData> get serializer =>
      _$gEnableConnectorDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GEnableConnectorData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GEnableConnectorData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GEnableConnectorData.serializer,
        json,
      );
}

abstract class GEnableConnectorData_enableConnector
    implements
        Built<GEnableConnectorData_enableConnector,
            GEnableConnectorData_enableConnectorBuilder> {
  GEnableConnectorData_enableConnector._();

  factory GEnableConnectorData_enableConnector(
      [void Function(GEnableConnectorData_enableConnectorBuilder b)
          updates]) = _$GEnableConnectorData_enableConnector;

  static void _initializeBuilder(
          GEnableConnectorData_enableConnectorBuilder b) =>
      b..G__typename = 'Connector';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  bool get enabled;
  static Serializer<GEnableConnectorData_enableConnector> get serializer =>
      _$gEnableConnectorDataEnableConnectorSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GEnableConnectorData_enableConnector.serializer,
        this,
      ) as Map<String, dynamic>);

  static GEnableConnectorData_enableConnector? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GEnableConnectorData_enableConnector.serializer,
        json,
      );
}
