// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'inbox_state.var.gql.g.dart';

abstract class GMarkInboxReadVars
    implements Built<GMarkInboxReadVars, GMarkInboxReadVarsBuilder> {
  GMarkInboxReadVars._();

  factory GMarkInboxReadVars(
          [void Function(GMarkInboxReadVarsBuilder b) updates]) =
      _$GMarkInboxReadVars;

  String get id;
  static Serializer<GMarkInboxReadVars> get serializer =>
      _$gMarkInboxReadVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GMarkInboxReadVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GMarkInboxReadVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GMarkInboxReadVars.serializer,
        json,
      );
}

abstract class GDismissInboxMessageVars
    implements
        Built<GDismissInboxMessageVars, GDismissInboxMessageVarsBuilder> {
  GDismissInboxMessageVars._();

  factory GDismissInboxMessageVars(
          [void Function(GDismissInboxMessageVarsBuilder b) updates]) =
      _$GDismissInboxMessageVars;

  String get id;
  static Serializer<GDismissInboxMessageVars> get serializer =>
      _$gDismissInboxMessageVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDismissInboxMessageVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDismissInboxMessageVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDismissInboxMessageVars.serializer,
        json,
      );
}
