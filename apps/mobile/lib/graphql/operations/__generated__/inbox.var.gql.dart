// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'inbox.var.gql.g.dart';

abstract class GInboxVars implements Built<GInboxVars, GInboxVarsBuilder> {
  GInboxVars._();

  factory GInboxVars([void Function(GInboxVarsBuilder b) updates]) =
      _$GInboxVars;

  int? get first;
  String? get after;
  static Serializer<GInboxVars> get serializer => _$gInboxVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxVars.serializer,
        json,
      );
}
