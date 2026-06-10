// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'proposed_task.var.gql.g.dart';

abstract class GAcceptProposedTaskVars
    implements Built<GAcceptProposedTaskVars, GAcceptProposedTaskVarsBuilder> {
  GAcceptProposedTaskVars._();

  factory GAcceptProposedTaskVars(
          [void Function(GAcceptProposedTaskVarsBuilder b) updates]) =
      _$GAcceptProposedTaskVars;

  String get taskId;
  static Serializer<GAcceptProposedTaskVars> get serializer =>
      _$gAcceptProposedTaskVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAcceptProposedTaskVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAcceptProposedTaskVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAcceptProposedTaskVars.serializer,
        json,
      );
}

abstract class GDismissProposedTaskVars
    implements
        Built<GDismissProposedTaskVars, GDismissProposedTaskVarsBuilder> {
  GDismissProposedTaskVars._();

  factory GDismissProposedTaskVars(
          [void Function(GDismissProposedTaskVarsBuilder b) updates]) =
      _$GDismissProposedTaskVars;

  String get taskId;
  String? get reason;
  static Serializer<GDismissProposedTaskVars> get serializer =>
      _$gDismissProposedTaskVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDismissProposedTaskVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDismissProposedTaskVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDismissProposedTaskVars.serializer,
        json,
      );
}
