// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GCategoriesData> _$gCategoriesDataSerializer =
    _$GCategoriesDataSerializer();
Serializer<GCategoriesData_categories> _$gCategoriesDataCategoriesSerializer =
    _$GCategoriesData_categoriesSerializer();
Serializer<GCategoriesData_categories_parent>
    _$gCategoriesDataCategoriesParentSerializer =
    _$GCategoriesData_categories_parentSerializer();
Serializer<GSetTaskCategoryData> _$gSetTaskCategoryDataSerializer =
    _$GSetTaskCategoryDataSerializer();
Serializer<GSetTaskCategoryData_setTaskCategory>
    _$gSetTaskCategoryDataSetTaskCategorySerializer =
    _$GSetTaskCategoryData_setTaskCategorySerializer();
Serializer<GDeleteTaskCategoryData> _$gDeleteTaskCategoryDataSerializer =
    _$GDeleteTaskCategoryDataSerializer();

class _$GCategoriesDataSerializer
    implements StructuredSerializer<GCategoriesData> {
  @override
  final Iterable<Type> types = const [GCategoriesData, _$GCategoriesData];
  @override
  final String wireName = 'GCategoriesData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GCategoriesData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'categories',
      serializers.serialize(object.categories,
          specifiedType: const FullType(
              BuiltList, const [const FullType(GCategoriesData_categories)])),
    ];

    return result;
  }

  @override
  GCategoriesData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCategoriesDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'categories':
          result.categories.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GCategoriesData_categories)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GCategoriesData_categoriesSerializer
    implements StructuredSerializer<GCategoriesData_categories> {
  @override
  final Iterable<Type> types = const [
    GCategoriesData_categories,
    _$GCategoriesData_categories
  ];
  @override
  final String wireName = 'GCategoriesData_categories';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GCategoriesData_categories object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
      'label',
      serializers.serialize(object.label,
          specifiedType: const FullType(String)),
      'stageBindings',
      serializers.serialize(object.stageBindings,
          specifiedType: const FullType(_i2.JsonObject)),
    ];
    Object? value;
    value = object.description;
    if (value != null) {
      result
        ..add('description')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.parent;
    if (value != null) {
      result
        ..add('parent')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GCategoriesData_categories_parent)));
    }
    return result;
  }

  @override
  GCategoriesData_categories deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCategoriesData_categoriesBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'key':
          result.key = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'label':
          result.label = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'description':
          result.description = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'parent':
          result.parent.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GCategoriesData_categories_parent))!
              as GCategoriesData_categories_parent);
          break;
        case 'stageBindings':
          result.stageBindings = serializers.deserialize(value,
              specifiedType: const FullType(_i2.JsonObject))! as _i2.JsonObject;
          break;
      }
    }

    return result.build();
  }
}

class _$GCategoriesData_categories_parentSerializer
    implements StructuredSerializer<GCategoriesData_categories_parent> {
  @override
  final Iterable<Type> types = const [
    GCategoriesData_categories_parent,
    _$GCategoriesData_categories_parent
  ];
  @override
  final String wireName = 'GCategoriesData_categories_parent';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GCategoriesData_categories_parent object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GCategoriesData_categories_parent deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCategoriesData_categories_parentBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'key':
          result.key = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GSetTaskCategoryDataSerializer
    implements StructuredSerializer<GSetTaskCategoryData> {
  @override
  final Iterable<Type> types = const [
    GSetTaskCategoryData,
    _$GSetTaskCategoryData
  ];
  @override
  final String wireName = 'GSetTaskCategoryData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSetTaskCategoryData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'setTaskCategory',
      serializers.serialize(object.setTaskCategory,
          specifiedType: const FullType(GSetTaskCategoryData_setTaskCategory)),
    ];

    return result;
  }

  @override
  GSetTaskCategoryData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSetTaskCategoryDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'setTaskCategory':
          result.setTaskCategory.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GSetTaskCategoryData_setTaskCategory))!
              as GSetTaskCategoryData_setTaskCategory);
          break;
      }
    }

    return result.build();
  }
}

class _$GSetTaskCategoryData_setTaskCategorySerializer
    implements StructuredSerializer<GSetTaskCategoryData_setTaskCategory> {
  @override
  final Iterable<Type> types = const [
    GSetTaskCategoryData_setTaskCategory,
    _$GSetTaskCategoryData_setTaskCategory
  ];
  @override
  final String wireName = 'GSetTaskCategoryData_setTaskCategory';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSetTaskCategoryData_setTaskCategory object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'key',
      serializers.serialize(object.key, specifiedType: const FullType(String)),
      'label',
      serializers.serialize(object.label,
          specifiedType: const FullType(String)),
      'stageBindings',
      serializers.serialize(object.stageBindings,
          specifiedType: const FullType(_i2.JsonObject)),
    ];
    Object? value;
    value = object.description;
    if (value != null) {
      result
        ..add('description')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GSetTaskCategoryData_setTaskCategory deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSetTaskCategoryData_setTaskCategoryBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'key':
          result.key = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'label':
          result.label = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'description':
          result.description = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'stageBindings':
          result.stageBindings = serializers.deserialize(value,
              specifiedType: const FullType(_i2.JsonObject))! as _i2.JsonObject;
          break;
      }
    }

    return result.build();
  }
}

class _$GDeleteTaskCategoryDataSerializer
    implements StructuredSerializer<GDeleteTaskCategoryData> {
  @override
  final Iterable<Type> types = const [
    GDeleteTaskCategoryData,
    _$GDeleteTaskCategoryData
  ];
  @override
  final String wireName = 'GDeleteTaskCategoryData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDeleteTaskCategoryData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'deleteTaskCategory',
      serializers.serialize(object.deleteTaskCategory,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  GDeleteTaskCategoryData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDeleteTaskCategoryDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'deleteTaskCategory':
          result.deleteTaskCategory = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GCategoriesData extends GCategoriesData {
  @override
  final String G__typename;
  @override
  final BuiltList<GCategoriesData_categories> categories;

  factory _$GCategoriesData([void Function(GCategoriesDataBuilder)? updates]) =>
      (GCategoriesDataBuilder()..update(updates))._build();

  _$GCategoriesData._({required this.G__typename, required this.categories})
      : super._();
  @override
  GCategoriesData rebuild(void Function(GCategoriesDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCategoriesDataBuilder toBuilder() => GCategoriesDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCategoriesData &&
        G__typename == other.G__typename &&
        categories == other.categories;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, categories.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCategoriesData')
          ..add('G__typename', G__typename)
          ..add('categories', categories))
        .toString();
  }
}

class GCategoriesDataBuilder
    implements Builder<GCategoriesData, GCategoriesDataBuilder> {
  _$GCategoriesData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  ListBuilder<GCategoriesData_categories>? _categories;
  ListBuilder<GCategoriesData_categories> get categories =>
      _$this._categories ??= ListBuilder<GCategoriesData_categories>();
  set categories(ListBuilder<GCategoriesData_categories>? categories) =>
      _$this._categories = categories;

  GCategoriesDataBuilder() {
    GCategoriesData._initializeBuilder(this);
  }

  GCategoriesDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _categories = $v.categories.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCategoriesData other) {
    _$v = other as _$GCategoriesData;
  }

  @override
  void update(void Function(GCategoriesDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCategoriesData build() => _build();

  _$GCategoriesData _build() {
    _$GCategoriesData _$result;
    try {
      _$result = _$v ??
          _$GCategoriesData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GCategoriesData', 'G__typename'),
            categories: categories.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'categories';
        categories.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GCategoriesData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GCategoriesData_categories extends GCategoriesData_categories {
  @override
  final String G__typename;
  @override
  final String key;
  @override
  final String label;
  @override
  final String? description;
  @override
  final GCategoriesData_categories_parent? parent;
  @override
  final _i2.JsonObject stageBindings;

  factory _$GCategoriesData_categories(
          [void Function(GCategoriesData_categoriesBuilder)? updates]) =>
      (GCategoriesData_categoriesBuilder()..update(updates))._build();

  _$GCategoriesData_categories._(
      {required this.G__typename,
      required this.key,
      required this.label,
      this.description,
      this.parent,
      required this.stageBindings})
      : super._();
  @override
  GCategoriesData_categories rebuild(
          void Function(GCategoriesData_categoriesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCategoriesData_categoriesBuilder toBuilder() =>
      GCategoriesData_categoriesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCategoriesData_categories &&
        G__typename == other.G__typename &&
        key == other.key &&
        label == other.label &&
        description == other.description &&
        parent == other.parent &&
        stageBindings == other.stageBindings;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, parent.hashCode);
    _$hash = $jc(_$hash, stageBindings.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCategoriesData_categories')
          ..add('G__typename', G__typename)
          ..add('key', key)
          ..add('label', label)
          ..add('description', description)
          ..add('parent', parent)
          ..add('stageBindings', stageBindings))
        .toString();
  }
}

class GCategoriesData_categoriesBuilder
    implements
        Builder<GCategoriesData_categories, GCategoriesData_categoriesBuilder> {
  _$GCategoriesData_categories? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  GCategoriesData_categories_parentBuilder? _parent;
  GCategoriesData_categories_parentBuilder get parent =>
      _$this._parent ??= GCategoriesData_categories_parentBuilder();
  set parent(GCategoriesData_categories_parentBuilder? parent) =>
      _$this._parent = parent;

  _i2.JsonObject? _stageBindings;
  _i2.JsonObject? get stageBindings => _$this._stageBindings;
  set stageBindings(_i2.JsonObject? stageBindings) =>
      _$this._stageBindings = stageBindings;

  GCategoriesData_categoriesBuilder() {
    GCategoriesData_categories._initializeBuilder(this);
  }

  GCategoriesData_categoriesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _key = $v.key;
      _label = $v.label;
      _description = $v.description;
      _parent = $v.parent?.toBuilder();
      _stageBindings = $v.stageBindings;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCategoriesData_categories other) {
    _$v = other as _$GCategoriesData_categories;
  }

  @override
  void update(void Function(GCategoriesData_categoriesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCategoriesData_categories build() => _build();

  _$GCategoriesData_categories _build() {
    _$GCategoriesData_categories _$result;
    try {
      _$result = _$v ??
          _$GCategoriesData_categories._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GCategoriesData_categories', 'G__typename'),
            key: BuiltValueNullFieldError.checkNotNull(
                key, r'GCategoriesData_categories', 'key'),
            label: BuiltValueNullFieldError.checkNotNull(
                label, r'GCategoriesData_categories', 'label'),
            description: description,
            parent: _parent?.build(),
            stageBindings: BuiltValueNullFieldError.checkNotNull(
                stageBindings, r'GCategoriesData_categories', 'stageBindings'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'parent';
        _parent?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GCategoriesData_categories', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GCategoriesData_categories_parent
    extends GCategoriesData_categories_parent {
  @override
  final String G__typename;
  @override
  final String key;

  factory _$GCategoriesData_categories_parent(
          [void Function(GCategoriesData_categories_parentBuilder)? updates]) =>
      (GCategoriesData_categories_parentBuilder()..update(updates))._build();

  _$GCategoriesData_categories_parent._(
      {required this.G__typename, required this.key})
      : super._();
  @override
  GCategoriesData_categories_parent rebuild(
          void Function(GCategoriesData_categories_parentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCategoriesData_categories_parentBuilder toBuilder() =>
      GCategoriesData_categories_parentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCategoriesData_categories_parent &&
        G__typename == other.G__typename &&
        key == other.key;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCategoriesData_categories_parent')
          ..add('G__typename', G__typename)
          ..add('key', key))
        .toString();
  }
}

class GCategoriesData_categories_parentBuilder
    implements
        Builder<GCategoriesData_categories_parent,
            GCategoriesData_categories_parentBuilder> {
  _$GCategoriesData_categories_parent? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  GCategoriesData_categories_parentBuilder() {
    GCategoriesData_categories_parent._initializeBuilder(this);
  }

  GCategoriesData_categories_parentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _key = $v.key;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCategoriesData_categories_parent other) {
    _$v = other as _$GCategoriesData_categories_parent;
  }

  @override
  void update(
      void Function(GCategoriesData_categories_parentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCategoriesData_categories_parent build() => _build();

  _$GCategoriesData_categories_parent _build() {
    final _$result = _$v ??
        _$GCategoriesData_categories_parent._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GCategoriesData_categories_parent', 'G__typename'),
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'GCategoriesData_categories_parent', 'key'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GSetTaskCategoryData extends GSetTaskCategoryData {
  @override
  final String G__typename;
  @override
  final GSetTaskCategoryData_setTaskCategory setTaskCategory;

  factory _$GSetTaskCategoryData(
          [void Function(GSetTaskCategoryDataBuilder)? updates]) =>
      (GSetTaskCategoryDataBuilder()..update(updates))._build();

  _$GSetTaskCategoryData._(
      {required this.G__typename, required this.setTaskCategory})
      : super._();
  @override
  GSetTaskCategoryData rebuild(
          void Function(GSetTaskCategoryDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSetTaskCategoryDataBuilder toBuilder() =>
      GSetTaskCategoryDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSetTaskCategoryData &&
        G__typename == other.G__typename &&
        setTaskCategory == other.setTaskCategory;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, setTaskCategory.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSetTaskCategoryData')
          ..add('G__typename', G__typename)
          ..add('setTaskCategory', setTaskCategory))
        .toString();
  }
}

class GSetTaskCategoryDataBuilder
    implements Builder<GSetTaskCategoryData, GSetTaskCategoryDataBuilder> {
  _$GSetTaskCategoryData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GSetTaskCategoryData_setTaskCategoryBuilder? _setTaskCategory;
  GSetTaskCategoryData_setTaskCategoryBuilder get setTaskCategory =>
      _$this._setTaskCategory ??= GSetTaskCategoryData_setTaskCategoryBuilder();
  set setTaskCategory(
          GSetTaskCategoryData_setTaskCategoryBuilder? setTaskCategory) =>
      _$this._setTaskCategory = setTaskCategory;

  GSetTaskCategoryDataBuilder() {
    GSetTaskCategoryData._initializeBuilder(this);
  }

  GSetTaskCategoryDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _setTaskCategory = $v.setTaskCategory.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSetTaskCategoryData other) {
    _$v = other as _$GSetTaskCategoryData;
  }

  @override
  void update(void Function(GSetTaskCategoryDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSetTaskCategoryData build() => _build();

  _$GSetTaskCategoryData _build() {
    _$GSetTaskCategoryData _$result;
    try {
      _$result = _$v ??
          _$GSetTaskCategoryData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GSetTaskCategoryData', 'G__typename'),
            setTaskCategory: setTaskCategory.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'setTaskCategory';
        setTaskCategory.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GSetTaskCategoryData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GSetTaskCategoryData_setTaskCategory
    extends GSetTaskCategoryData_setTaskCategory {
  @override
  final String G__typename;
  @override
  final String key;
  @override
  final String label;
  @override
  final String? description;
  @override
  final _i2.JsonObject stageBindings;

  factory _$GSetTaskCategoryData_setTaskCategory(
          [void Function(GSetTaskCategoryData_setTaskCategoryBuilder)?
              updates]) =>
      (GSetTaskCategoryData_setTaskCategoryBuilder()..update(updates))._build();

  _$GSetTaskCategoryData_setTaskCategory._(
      {required this.G__typename,
      required this.key,
      required this.label,
      this.description,
      required this.stageBindings})
      : super._();
  @override
  GSetTaskCategoryData_setTaskCategory rebuild(
          void Function(GSetTaskCategoryData_setTaskCategoryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSetTaskCategoryData_setTaskCategoryBuilder toBuilder() =>
      GSetTaskCategoryData_setTaskCategoryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSetTaskCategoryData_setTaskCategory &&
        G__typename == other.G__typename &&
        key == other.key &&
        label == other.label &&
        description == other.description &&
        stageBindings == other.stageBindings;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, stageBindings.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSetTaskCategoryData_setTaskCategory')
          ..add('G__typename', G__typename)
          ..add('key', key)
          ..add('label', label)
          ..add('description', description)
          ..add('stageBindings', stageBindings))
        .toString();
  }
}

class GSetTaskCategoryData_setTaskCategoryBuilder
    implements
        Builder<GSetTaskCategoryData_setTaskCategory,
            GSetTaskCategoryData_setTaskCategoryBuilder> {
  _$GSetTaskCategoryData_setTaskCategory? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  _i2.JsonObject? _stageBindings;
  _i2.JsonObject? get stageBindings => _$this._stageBindings;
  set stageBindings(_i2.JsonObject? stageBindings) =>
      _$this._stageBindings = stageBindings;

  GSetTaskCategoryData_setTaskCategoryBuilder() {
    GSetTaskCategoryData_setTaskCategory._initializeBuilder(this);
  }

  GSetTaskCategoryData_setTaskCategoryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _key = $v.key;
      _label = $v.label;
      _description = $v.description;
      _stageBindings = $v.stageBindings;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSetTaskCategoryData_setTaskCategory other) {
    _$v = other as _$GSetTaskCategoryData_setTaskCategory;
  }

  @override
  void update(
      void Function(GSetTaskCategoryData_setTaskCategoryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSetTaskCategoryData_setTaskCategory build() => _build();

  _$GSetTaskCategoryData_setTaskCategory _build() {
    final _$result = _$v ??
        _$GSetTaskCategoryData_setTaskCategory._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GSetTaskCategoryData_setTaskCategory', 'G__typename'),
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'GSetTaskCategoryData_setTaskCategory', 'key'),
          label: BuiltValueNullFieldError.checkNotNull(
              label, r'GSetTaskCategoryData_setTaskCategory', 'label'),
          description: description,
          stageBindings: BuiltValueNullFieldError.checkNotNull(stageBindings,
              r'GSetTaskCategoryData_setTaskCategory', 'stageBindings'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GDeleteTaskCategoryData extends GDeleteTaskCategoryData {
  @override
  final String G__typename;
  @override
  final bool deleteTaskCategory;

  factory _$GDeleteTaskCategoryData(
          [void Function(GDeleteTaskCategoryDataBuilder)? updates]) =>
      (GDeleteTaskCategoryDataBuilder()..update(updates))._build();

  _$GDeleteTaskCategoryData._(
      {required this.G__typename, required this.deleteTaskCategory})
      : super._();
  @override
  GDeleteTaskCategoryData rebuild(
          void Function(GDeleteTaskCategoryDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDeleteTaskCategoryDataBuilder toBuilder() =>
      GDeleteTaskCategoryDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDeleteTaskCategoryData &&
        G__typename == other.G__typename &&
        deleteTaskCategory == other.deleteTaskCategory;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, deleteTaskCategory.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GDeleteTaskCategoryData')
          ..add('G__typename', G__typename)
          ..add('deleteTaskCategory', deleteTaskCategory))
        .toString();
  }
}

class GDeleteTaskCategoryDataBuilder
    implements
        Builder<GDeleteTaskCategoryData, GDeleteTaskCategoryDataBuilder> {
  _$GDeleteTaskCategoryData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _deleteTaskCategory;
  bool? get deleteTaskCategory => _$this._deleteTaskCategory;
  set deleteTaskCategory(bool? deleteTaskCategory) =>
      _$this._deleteTaskCategory = deleteTaskCategory;

  GDeleteTaskCategoryDataBuilder() {
    GDeleteTaskCategoryData._initializeBuilder(this);
  }

  GDeleteTaskCategoryDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _deleteTaskCategory = $v.deleteTaskCategory;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDeleteTaskCategoryData other) {
    _$v = other as _$GDeleteTaskCategoryData;
  }

  @override
  void update(void Function(GDeleteTaskCategoryDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDeleteTaskCategoryData build() => _build();

  _$GDeleteTaskCategoryData _build() {
    final _$result = _$v ??
        _$GDeleteTaskCategoryData._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GDeleteTaskCategoryData', 'G__typename'),
          deleteTaskCategory: BuiltValueNullFieldError.checkNotNull(
              deleteTaskCategory,
              r'GDeleteTaskCategoryData',
              'deleteTaskCategory'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
