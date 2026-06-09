// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'pair_device.var.gql.g.dart';

abstract class GPairDeviceVars
    implements Built<GPairDeviceVars, GPairDeviceVarsBuilder> {
  GPairDeviceVars._();

  factory GPairDeviceVars([void Function(GPairDeviceVarsBuilder b) updates]) =
      _$GPairDeviceVars;

  String get password;
  String get displayName;
  static Serializer<GPairDeviceVars> get serializer =>
      _$gPairDeviceVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GPairDeviceVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GPairDeviceVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GPairDeviceVars.serializer,
        json,
      );
}
