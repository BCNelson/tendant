// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart' as _i2;
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'connectors.var.gql.g.dart';

abstract class GConnectorsVars
    implements Built<GConnectorsVars, GConnectorsVarsBuilder> {
  GConnectorsVars._();

  factory GConnectorsVars([void Function(GConnectorsVarsBuilder b) updates]) =
      _$GConnectorsVars;

  static Serializer<GConnectorsVars> get serializer =>
      _$gConnectorsVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GConnectorsVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GConnectorsVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GConnectorsVars.serializer,
        json,
      );
}

abstract class GSetConnectorConfigVars
    implements Built<GSetConnectorConfigVars, GSetConnectorConfigVarsBuilder> {
  GSetConnectorConfigVars._();

  factory GSetConnectorConfigVars(
          [void Function(GSetConnectorConfigVarsBuilder b) updates]) =
      _$GSetConnectorConfigVars;

  String get connectorId;
  _i2.JsonObject get config;
  static Serializer<GSetConnectorConfigVars> get serializer =>
      _$gSetConnectorConfigVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSetConnectorConfigVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSetConnectorConfigVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSetConnectorConfigVars.serializer,
        json,
      );
}

abstract class GEnableConnectorVars
    implements Built<GEnableConnectorVars, GEnableConnectorVarsBuilder> {
  GEnableConnectorVars._();

  factory GEnableConnectorVars(
          [void Function(GEnableConnectorVarsBuilder b) updates]) =
      _$GEnableConnectorVars;

  String get connectorId;
  bool get enabled;
  static Serializer<GEnableConnectorVars> get serializer =>
      _$gEnableConnectorVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GEnableConnectorVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GEnableConnectorVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GEnableConnectorVars.serializer,
        json,
      );
}
