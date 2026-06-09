// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'pair_device.data.gql.g.dart';

abstract class GPairDeviceData
    implements Built<GPairDeviceData, GPairDeviceDataBuilder> {
  GPairDeviceData._();

  factory GPairDeviceData([void Function(GPairDeviceDataBuilder b) updates]) =
      _$GPairDeviceData;

  static void _initializeBuilder(GPairDeviceDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GPairDeviceData_pairDevice get pairDevice;
  static Serializer<GPairDeviceData> get serializer =>
      _$gPairDeviceDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPairDeviceData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPairDeviceData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPairDeviceData.serializer,
        json,
      );
}

abstract class GPairDeviceData_pairDevice
    implements
        Built<GPairDeviceData_pairDevice, GPairDeviceData_pairDeviceBuilder> {
  GPairDeviceData_pairDevice._();

  factory GPairDeviceData_pairDevice(
          [void Function(GPairDeviceData_pairDeviceBuilder b) updates]) =
      _$GPairDeviceData_pairDevice;

  static void _initializeBuilder(GPairDeviceData_pairDeviceBuilder b) =>
      b..G__typename = 'SessionMintResult';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GPairDeviceData_pairDevice_session get session;
  String get token;
  static Serializer<GPairDeviceData_pairDevice> get serializer =>
      _$gPairDeviceDataPairDeviceSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPairDeviceData_pairDevice.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPairDeviceData_pairDevice? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPairDeviceData_pairDevice.serializer,
        json,
      );
}

abstract class GPairDeviceData_pairDevice_session
    implements
        Built<GPairDeviceData_pairDevice_session,
            GPairDeviceData_pairDevice_sessionBuilder> {
  GPairDeviceData_pairDevice_session._();

  factory GPairDeviceData_pairDevice_session(
      [void Function(GPairDeviceData_pairDevice_sessionBuilder b)
          updates]) = _$GPairDeviceData_pairDevice_session;

  static void _initializeBuilder(GPairDeviceData_pairDevice_sessionBuilder b) =>
      b..G__typename = 'Session';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get displayName;
  _i2.GTime get createdAt;
  _i2.GTime get lastSeenAt;
  static Serializer<GPairDeviceData_pairDevice_session> get serializer =>
      _$gPairDeviceDataPairDeviceSessionSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPairDeviceData_pairDevice_session.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPairDeviceData_pairDevice_session? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPairDeviceData_pairDevice_session.serializer,
        json,
      );
}
