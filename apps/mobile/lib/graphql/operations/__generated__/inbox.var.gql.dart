// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'inbox.var.gql.g.dart';

abstract class GInboxFeedVars
    implements Built<GInboxFeedVars, GInboxFeedVarsBuilder> {
  GInboxFeedVars._();

  factory GInboxFeedVars([void Function(GInboxFeedVarsBuilder b) updates]) =
      _$GInboxFeedVars;

  int? get first;
  String? get after;
  static Serializer<GInboxFeedVars> get serializer =>
      _$gInboxFeedVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxFeedVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxFeedVars.serializer,
        json,
      );
}
