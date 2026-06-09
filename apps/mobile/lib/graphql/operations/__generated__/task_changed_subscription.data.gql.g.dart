// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_changed_subscription.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GTaskChangedData> _$gTaskChangedDataSerializer =
    _$GTaskChangedDataSerializer();
Serializer<GTaskChangedData_taskChanged>
    _$gTaskChangedDataTaskChangedSerializer =
    _$GTaskChangedData_taskChangedSerializer();

class _$GTaskChangedDataSerializer
    implements StructuredSerializer<GTaskChangedData> {
  @override
  final Iterable<Type> types = const [GTaskChangedData, _$GTaskChangedData];
  @override
  final String wireName = 'GTaskChangedData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GTaskChangedData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'taskChanged',
      serializers.serialize(object.taskChanged,
          specifiedType: const FullType(GTaskChangedData_taskChanged)),
    ];

    return result;
  }

  @override
  GTaskChangedData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskChangedDataBuilder();

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
        case 'taskChanged':
          result.taskChanged.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GTaskChangedData_taskChanged))!
              as GTaskChangedData_taskChanged);
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskChangedData_taskChangedSerializer
    implements StructuredSerializer<GTaskChangedData_taskChanged> {
  @override
  final Iterable<Type> types = const [
    GTaskChangedData_taskChanged,
    _$GTaskChangedData_taskChanged
  ];
  @override
  final String wireName = 'GTaskChangedData_taskChanged';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskChangedData_taskChanged object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'state',
      serializers.serialize(object.state,
          specifiedType: const FullType(_i2.GTaskState)),
      'currentStage',
      serializers.serialize(object.currentStage,
          specifiedType: const FullType(_i2.GChainStage)),
    ];

    return result;
  }

  @override
  GTaskChangedData_taskChanged deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskChangedData_taskChangedBuilder();

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
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'state':
          result.state = serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTaskState))! as _i2.GTaskState;
          break;
        case 'currentStage':
          result.currentStage = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GChainStage))!
              as _i2.GChainStage;
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskChangedData extends GTaskChangedData {
  @override
  final String G__typename;
  @override
  final GTaskChangedData_taskChanged taskChanged;

  factory _$GTaskChangedData(
          [void Function(GTaskChangedDataBuilder)? updates]) =>
      (GTaskChangedDataBuilder()..update(updates))._build();

  _$GTaskChangedData._({required this.G__typename, required this.taskChanged})
      : super._();
  @override
  GTaskChangedData rebuild(void Function(GTaskChangedDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskChangedDataBuilder toBuilder() =>
      GTaskChangedDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskChangedData &&
        G__typename == other.G__typename &&
        taskChanged == other.taskChanged;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, taskChanged.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTaskChangedData')
          ..add('G__typename', G__typename)
          ..add('taskChanged', taskChanged))
        .toString();
  }
}

class GTaskChangedDataBuilder
    implements Builder<GTaskChangedData, GTaskChangedDataBuilder> {
  _$GTaskChangedData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GTaskChangedData_taskChangedBuilder? _taskChanged;
  GTaskChangedData_taskChangedBuilder get taskChanged =>
      _$this._taskChanged ??= GTaskChangedData_taskChangedBuilder();
  set taskChanged(GTaskChangedData_taskChangedBuilder? taskChanged) =>
      _$this._taskChanged = taskChanged;

  GTaskChangedDataBuilder() {
    GTaskChangedData._initializeBuilder(this);
  }

  GTaskChangedDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _taskChanged = $v.taskChanged.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskChangedData other) {
    _$v = other as _$GTaskChangedData;
  }

  @override
  void update(void Function(GTaskChangedDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskChangedData build() => _build();

  _$GTaskChangedData _build() {
    _$GTaskChangedData _$result;
    try {
      _$result = _$v ??
          _$GTaskChangedData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GTaskChangedData', 'G__typename'),
            taskChanged: taskChanged.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taskChanged';
        taskChanged.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GTaskChangedData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTaskChangedData_taskChanged extends GTaskChangedData_taskChanged {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GTaskState state;
  @override
  final _i2.GChainStage currentStage;

  factory _$GTaskChangedData_taskChanged(
          [void Function(GTaskChangedData_taskChangedBuilder)? updates]) =>
      (GTaskChangedData_taskChangedBuilder()..update(updates))._build();

  _$GTaskChangedData_taskChanged._(
      {required this.G__typename,
      required this.id,
      required this.state,
      required this.currentStage})
      : super._();
  @override
  GTaskChangedData_taskChanged rebuild(
          void Function(GTaskChangedData_taskChangedBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskChangedData_taskChangedBuilder toBuilder() =>
      GTaskChangedData_taskChangedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskChangedData_taskChanged &&
        G__typename == other.G__typename &&
        id == other.id &&
        state == other.state &&
        currentStage == other.currentStage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, currentStage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTaskChangedData_taskChanged')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('state', state)
          ..add('currentStage', currentStage))
        .toString();
  }
}

class GTaskChangedData_taskChangedBuilder
    implements
        Builder<GTaskChangedData_taskChanged,
            GTaskChangedData_taskChangedBuilder> {
  _$GTaskChangedData_taskChanged? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GTaskState? _state;
  _i2.GTaskState? get state => _$this._state;
  set state(_i2.GTaskState? state) => _$this._state = state;

  _i2.GChainStage? _currentStage;
  _i2.GChainStage? get currentStage => _$this._currentStage;
  set currentStage(_i2.GChainStage? currentStage) =>
      _$this._currentStage = currentStage;

  GTaskChangedData_taskChangedBuilder() {
    GTaskChangedData_taskChanged._initializeBuilder(this);
  }

  GTaskChangedData_taskChangedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _state = $v.state;
      _currentStage = $v.currentStage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskChangedData_taskChanged other) {
    _$v = other as _$GTaskChangedData_taskChanged;
  }

  @override
  void update(void Function(GTaskChangedData_taskChangedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskChangedData_taskChanged build() => _build();

  _$GTaskChangedData_taskChanged _build() {
    final _$result = _$v ??
        _$GTaskChangedData_taskChanged._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GTaskChangedData_taskChanged', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTaskChangedData_taskChanged', 'id'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GTaskChangedData_taskChanged', 'state'),
          currentStage: BuiltValueNullFieldError.checkNotNull(
              currentStage, r'GTaskChangedData_taskChanged', 'currentStage'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
