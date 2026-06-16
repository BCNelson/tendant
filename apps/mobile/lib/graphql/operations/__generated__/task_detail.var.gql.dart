// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'task_detail.var.gql.g.dart';

abstract class GTaskDetailVars
    implements Built<GTaskDetailVars, GTaskDetailVarsBuilder> {
  GTaskDetailVars._();

  factory GTaskDetailVars([void Function(GTaskDetailVarsBuilder b) updates]) =
      _$GTaskDetailVars;

  String get id;
  static Serializer<GTaskDetailVars> get serializer =>
      _$gTaskDetailVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskDetailVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskDetailVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskDetailVars.serializer,
        json,
      );
}

abstract class GTaskLinkVars
    implements Built<GTaskLinkVars, GTaskLinkVarsBuilder> {
  GTaskLinkVars._();

  factory GTaskLinkVars([void Function(GTaskLinkVarsBuilder b) updates]) =
      _$GTaskLinkVars;

  static Serializer<GTaskLinkVars> get serializer => _$gTaskLinkVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskLinkVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskLinkVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskLinkVars.serializer,
        json,
      );
}
