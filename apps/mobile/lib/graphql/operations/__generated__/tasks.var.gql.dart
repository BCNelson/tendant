// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i1;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i2;

part 'tasks.var.gql.g.dart';

abstract class GTasksVars implements Built<GTasksVars, GTasksVarsBuilder> {
  GTasksVars._();

  factory GTasksVars([void Function(GTasksVarsBuilder b) updates]) =
      _$GTasksVars;

  int? get first;
  String? get after;
  _i1.GTaskState? get state;
  static Serializer<GTasksVars> get serializer => _$gTasksVarsSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GTasksVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTasksVars? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GTasksVars.serializer,
        json,
      );
}
