// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'inbox_subscription.var.gql.g.dart';

abstract class GInboxItemArrivedVars
    implements Built<GInboxItemArrivedVars, GInboxItemArrivedVarsBuilder> {
  GInboxItemArrivedVars._();

  factory GInboxItemArrivedVars(
          [void Function(GInboxItemArrivedVarsBuilder b) updates]) =
      _$GInboxItemArrivedVars;

  static Serializer<GInboxItemArrivedVars> get serializer =>
      _$gInboxItemArrivedVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxItemArrivedVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxItemArrivedVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxItemArrivedVars.serializer,
        json,
      );
}
