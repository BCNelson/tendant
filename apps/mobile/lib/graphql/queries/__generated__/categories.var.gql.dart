// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'categories.var.gql.g.dart';

abstract class GCategoriesVars
    implements Built<GCategoriesVars, GCategoriesVarsBuilder> {
  GCategoriesVars._();

  factory GCategoriesVars([void Function(GCategoriesVarsBuilder b) updates]) =
      _$GCategoriesVars;

  static Serializer<GCategoriesVars> get serializer =>
      _$gCategoriesVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCategoriesVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCategoriesVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCategoriesVars.serializer,
        json,
      );
}

abstract class GSetTaskCategoryVars
    implements Built<GSetTaskCategoryVars, GSetTaskCategoryVarsBuilder> {
  GSetTaskCategoryVars._();

  factory GSetTaskCategoryVars(
          [void Function(GSetTaskCategoryVarsBuilder b) updates]) =
      _$GSetTaskCategoryVars;

  _i2.GSetTaskCategoryInput get input;
  static Serializer<GSetTaskCategoryVars> get serializer =>
      _$gSetTaskCategoryVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSetTaskCategoryVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSetTaskCategoryVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSetTaskCategoryVars.serializer,
        json,
      );
}

abstract class GDeleteTaskCategoryVars
    implements Built<GDeleteTaskCategoryVars, GDeleteTaskCategoryVarsBuilder> {
  GDeleteTaskCategoryVars._();

  factory GDeleteTaskCategoryVars(
          [void Function(GDeleteTaskCategoryVarsBuilder b) updates]) =
      _$GDeleteTaskCategoryVars;

  String get key;
  static Serializer<GDeleteTaskCategoryVars> get serializer =>
      _$gDeleteTaskCategoryVarsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDeleteTaskCategoryVars.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeleteTaskCategoryVars? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDeleteTaskCategoryVars.serializer,
        json,
      );
}
