// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'config.var.gql.g.dart';

abstract class GConfigKeysVars
    implements Built<GConfigKeysVars, GConfigKeysVarsBuilder> {
  GConfigKeysVars._();

  factory GConfigKeysVars([void Function(GConfigKeysVarsBuilder b) updates]) =
      _$GConfigKeysVars;

  static Serializer<GConfigKeysVars> get serializer =>
      _$gConfigKeysVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GConfigKeysVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GConfigKeysVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GConfigKeysVars.serializer,
        json,
      );
}

abstract class GSetConfigEntryVars
    implements Built<GSetConfigEntryVars, GSetConfigEntryVarsBuilder> {
  GSetConfigEntryVars._();

  factory GSetConfigEntryVars(
          [void Function(GSetConfigEntryVarsBuilder b) updates]) =
      _$GSetConfigEntryVars;

  String get key;
  String get value;
  static Serializer<GSetConfigEntryVars> get serializer =>
      _$gSetConfigEntryVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSetConfigEntryVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSetConfigEntryVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSetConfigEntryVars.serializer,
        json,
      );
}

abstract class GDeleteConfigEntryVars
    implements Built<GDeleteConfigEntryVars, GDeleteConfigEntryVarsBuilder> {
  GDeleteConfigEntryVars._();

  factory GDeleteConfigEntryVars(
          [void Function(GDeleteConfigEntryVarsBuilder b) updates]) =
      _$GDeleteConfigEntryVars;

  String get key;
  static Serializer<GDeleteConfigEntryVars> get serializer =>
      _$gDeleteConfigEntryVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDeleteConfigEntryVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeleteConfigEntryVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDeleteConfigEntryVars.serializer,
        json,
      );
}
