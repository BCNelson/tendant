// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i2;

part 'register_device_token.var.gql.g.dart';

abstract class GRegisterDeviceTokenVars
    implements
        Built<GRegisterDeviceTokenVars, GRegisterDeviceTokenVarsBuilder> {
  GRegisterDeviceTokenVars._();

  factory GRegisterDeviceTokenVars(
          [void Function(GRegisterDeviceTokenVarsBuilder b) updates]) =
      _$GRegisterDeviceTokenVars;

  String get token;
  _i1.GDevicePlatform get platform;
  static Serializer<GRegisterDeviceTokenVars> get serializer =>
      _$gRegisterDeviceTokenVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GRegisterDeviceTokenVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRegisterDeviceTokenVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GRegisterDeviceTokenVars.serializer,
        json,
      );
}

abstract class GUnregisterDeviceTokenVars
    implements
        Built<GUnregisterDeviceTokenVars, GUnregisterDeviceTokenVarsBuilder> {
  GUnregisterDeviceTokenVars._();

  factory GUnregisterDeviceTokenVars(
          [void Function(GUnregisterDeviceTokenVarsBuilder b) updates]) =
      _$GUnregisterDeviceTokenVars;

  String get token;
  static Serializer<GUnregisterDeviceTokenVars> get serializer =>
      _$gUnregisterDeviceTokenVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GUnregisterDeviceTokenVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUnregisterDeviceTokenVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GUnregisterDeviceTokenVars.serializer,
        json,
      );
}
