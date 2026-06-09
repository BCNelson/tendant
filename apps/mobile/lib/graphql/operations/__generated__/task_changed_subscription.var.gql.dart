// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'task_changed_subscription.var.gql.g.dart';

abstract class GTaskChangedVars
    implements Built<GTaskChangedVars, GTaskChangedVarsBuilder> {
  GTaskChangedVars._();

  factory GTaskChangedVars([void Function(GTaskChangedVarsBuilder b) updates]) =
      _$GTaskChangedVars;

  String? get taskId;
  static Serializer<GTaskChangedVars> get serializer =>
      _$gTaskChangedVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskChangedVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskChangedVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskChangedVars.serializer,
        json,
      );
}
