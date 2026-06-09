// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart' as _i2;
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'categories.data.gql.g.dart';

abstract class GCategoriesData
    implements Built<GCategoriesData, GCategoriesDataBuilder> {
  GCategoriesData._();

  factory GCategoriesData([void Function(GCategoriesDataBuilder b) updates]) =
      _$GCategoriesData;

  static void _initializeBuilder(GCategoriesDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  BuiltList<GCategoriesData_categories> get categories;
  static Serializer<GCategoriesData> get serializer =>
      _$gCategoriesDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCategoriesData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCategoriesData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCategoriesData.serializer,
        json,
      );
}

abstract class GCategoriesData_categories
    implements
        Built<GCategoriesData_categories, GCategoriesData_categoriesBuilder> {
  GCategoriesData_categories._();

  factory GCategoriesData_categories(
          [void Function(GCategoriesData_categoriesBuilder b) updates]) =
      _$GCategoriesData_categories;

  static void _initializeBuilder(GCategoriesData_categoriesBuilder b) =>
      b..G__typename = 'TaskCategory';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get key;
  String get label;
  String? get description;
  GCategoriesData_categories_parent? get parent;
  _i2.JsonObject get stageBindings;
  static Serializer<GCategoriesData_categories> get serializer =>
      _$gCategoriesDataCategoriesSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCategoriesData_categories.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCategoriesData_categories? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCategoriesData_categories.serializer,
        json,
      );
}

abstract class GCategoriesData_categories_parent
    implements
        Built<GCategoriesData_categories_parent,
            GCategoriesData_categories_parentBuilder> {
  GCategoriesData_categories_parent._();

  factory GCategoriesData_categories_parent(
          [void Function(GCategoriesData_categories_parentBuilder b) updates]) =
      _$GCategoriesData_categories_parent;

  static void _initializeBuilder(GCategoriesData_categories_parentBuilder b) =>
      b..G__typename = 'TaskCategory';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get key;
  static Serializer<GCategoriesData_categories_parent> get serializer =>
      _$gCategoriesDataCategoriesParentSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCategoriesData_categories_parent.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCategoriesData_categories_parent? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCategoriesData_categories_parent.serializer,
        json,
      );
}

abstract class GSetTaskCategoryData
    implements Built<GSetTaskCategoryData, GSetTaskCategoryDataBuilder> {
  GSetTaskCategoryData._();

  factory GSetTaskCategoryData(
          [void Function(GSetTaskCategoryDataBuilder b) updates]) =
      _$GSetTaskCategoryData;

  static void _initializeBuilder(GSetTaskCategoryDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GSetTaskCategoryData_setTaskCategory get setTaskCategory;
  static Serializer<GSetTaskCategoryData> get serializer =>
      _$gSetTaskCategoryDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSetTaskCategoryData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSetTaskCategoryData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSetTaskCategoryData.serializer,
        json,
      );
}

abstract class GSetTaskCategoryData_setTaskCategory
    implements
        Built<GSetTaskCategoryData_setTaskCategory,
            GSetTaskCategoryData_setTaskCategoryBuilder> {
  GSetTaskCategoryData_setTaskCategory._();

  factory GSetTaskCategoryData_setTaskCategory(
      [void Function(GSetTaskCategoryData_setTaskCategoryBuilder b)
          updates]) = _$GSetTaskCategoryData_setTaskCategory;

  static void _initializeBuilder(
          GSetTaskCategoryData_setTaskCategoryBuilder b) =>
      b..G__typename = 'TaskCategory';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get key;
  String get label;
  String? get description;
  _i2.JsonObject get stageBindings;
  static Serializer<GSetTaskCategoryData_setTaskCategory> get serializer =>
      _$gSetTaskCategoryDataSetTaskCategorySerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSetTaskCategoryData_setTaskCategory.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSetTaskCategoryData_setTaskCategory? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSetTaskCategoryData_setTaskCategory.serializer,
        json,
      );
}

abstract class GDeleteTaskCategoryData
    implements Built<GDeleteTaskCategoryData, GDeleteTaskCategoryDataBuilder> {
  GDeleteTaskCategoryData._();

  factory GDeleteTaskCategoryData(
          [void Function(GDeleteTaskCategoryDataBuilder b) updates]) =
      _$GDeleteTaskCategoryData;

  static void _initializeBuilder(GDeleteTaskCategoryDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get deleteTaskCategory;
  static Serializer<GDeleteTaskCategoryData> get serializer =>
      _$gDeleteTaskCategoryDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDeleteTaskCategoryData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeleteTaskCategoryData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDeleteTaskCategoryData.serializer,
        json,
      );
}
