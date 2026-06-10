// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'inbox_subscription.var.gql.g.dart';

abstract class GInboxEntryArrivedVars
    implements Built<GInboxEntryArrivedVars, GInboxEntryArrivedVarsBuilder> {
  GInboxEntryArrivedVars._();

  factory GInboxEntryArrivedVars(
          [void Function(GInboxEntryArrivedVarsBuilder b) updates]) =
      _$GInboxEntryArrivedVars;

  static Serializer<GInboxEntryArrivedVars> get serializer =>
      _$gInboxEntryArrivedVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxEntryArrivedVars.serializer,
        json,
      );
}
