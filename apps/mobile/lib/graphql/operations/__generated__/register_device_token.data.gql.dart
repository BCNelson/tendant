// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'register_device_token.data.gql.g.dart';

abstract class GRegisterDeviceTokenData
    implements
        Built<GRegisterDeviceTokenData, GRegisterDeviceTokenDataBuilder> {
  GRegisterDeviceTokenData._();

  factory GRegisterDeviceTokenData(
          [void Function(GRegisterDeviceTokenDataBuilder b) updates]) =
      _$GRegisterDeviceTokenData;

  static void _initializeBuilder(GRegisterDeviceTokenDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get registerDeviceToken;
  static Serializer<GRegisterDeviceTokenData> get serializer =>
      _$gRegisterDeviceTokenDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRegisterDeviceTokenData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRegisterDeviceTokenData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRegisterDeviceTokenData.serializer,
        json,
      );
}

abstract class GUnregisterDeviceTokenData
    implements
        Built<GUnregisterDeviceTokenData, GUnregisterDeviceTokenDataBuilder> {
  GUnregisterDeviceTokenData._();

  factory GUnregisterDeviceTokenData(
          [void Function(GUnregisterDeviceTokenDataBuilder b) updates]) =
      _$GUnregisterDeviceTokenData;

  static void _initializeBuilder(GUnregisterDeviceTokenDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get unregisterDeviceToken;
  static Serializer<GUnregisterDeviceTokenData> get serializer =>
      _$gUnregisterDeviceTokenDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUnregisterDeviceTokenData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUnregisterDeviceTokenData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GUnregisterDeviceTokenData.serializer,
        json,
      );
}
