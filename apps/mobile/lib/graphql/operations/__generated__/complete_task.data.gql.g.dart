// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_task.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GCompleteTaskData> _$gCompleteTaskDataSerializer =
    _$GCompleteTaskDataSerializer();
Serializer<GCompleteTaskData_completeTask>
    _$gCompleteTaskDataCompleteTaskSerializer =
    _$GCompleteTaskData_completeTaskSerializer();

class _$GCompleteTaskDataSerializer
    implements StructuredSerializer<GCompleteTaskData> {
  @override
  final Iterable<Type> types = const [GCompleteTaskData, _$GCompleteTaskData];
  @override
  final String wireName = 'GCompleteTaskData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GCompleteTaskData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'completeTask',
      serializers.serialize(object.completeTask,
          specifiedType: const FullType(GCompleteTaskData_completeTask)),
    ];

    return result;
  }

  @override
  GCompleteTaskData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCompleteTaskDataBuilder();

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
        case 'completeTask':
          result.completeTask.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GCompleteTaskData_completeTask))!
              as GCompleteTaskData_completeTask);
          break;
      }
    }

    return result.build();
  }
}

class _$GCompleteTaskData_completeTaskSerializer
    implements StructuredSerializer<GCompleteTaskData_completeTask> {
  @override
  final Iterable<Type> types = const [
    GCompleteTaskData_completeTask,
    _$GCompleteTaskData_completeTask
  ];
  @override
  final String wireName = 'GCompleteTaskData_completeTask';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GCompleteTaskData_completeTask object,
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
  GCompleteTaskData_completeTask deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCompleteTaskData_completeTaskBuilder();

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

class _$GCompleteTaskData extends GCompleteTaskData {
  @override
  final String G__typename;
  @override
  final GCompleteTaskData_completeTask completeTask;

  factory _$GCompleteTaskData(
          [void Function(GCompleteTaskDataBuilder)? updates]) =>
      (GCompleteTaskDataBuilder()..update(updates))._build();

  _$GCompleteTaskData._({required this.G__typename, required this.completeTask})
      : super._();
  @override
  GCompleteTaskData rebuild(void Function(GCompleteTaskDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCompleteTaskDataBuilder toBuilder() =>
      GCompleteTaskDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCompleteTaskData &&
        G__typename == other.G__typename &&
        completeTask == other.completeTask;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, completeTask.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCompleteTaskData')
          ..add('G__typename', G__typename)
          ..add('completeTask', completeTask))
        .toString();
  }
}

class GCompleteTaskDataBuilder
    implements Builder<GCompleteTaskData, GCompleteTaskDataBuilder> {
  _$GCompleteTaskData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GCompleteTaskData_completeTaskBuilder? _completeTask;
  GCompleteTaskData_completeTaskBuilder get completeTask =>
      _$this._completeTask ??= GCompleteTaskData_completeTaskBuilder();
  set completeTask(GCompleteTaskData_completeTaskBuilder? completeTask) =>
      _$this._completeTask = completeTask;

  GCompleteTaskDataBuilder() {
    GCompleteTaskData._initializeBuilder(this);
  }

  GCompleteTaskDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _completeTask = $v.completeTask.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCompleteTaskData other) {
    _$v = other as _$GCompleteTaskData;
  }

  @override
  void update(void Function(GCompleteTaskDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCompleteTaskData build() => _build();

  _$GCompleteTaskData _build() {
    _$GCompleteTaskData _$result;
    try {
      _$result = _$v ??
          _$GCompleteTaskData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GCompleteTaskData', 'G__typename'),
            completeTask: completeTask.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'completeTask';
        completeTask.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GCompleteTaskData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GCompleteTaskData_completeTask extends GCompleteTaskData_completeTask {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GTaskState state;
  @override
  final _i2.GChainStage currentStage;

  factory _$GCompleteTaskData_completeTask(
          [void Function(GCompleteTaskData_completeTaskBuilder)? updates]) =>
      (GCompleteTaskData_completeTaskBuilder()..update(updates))._build();

  _$GCompleteTaskData_completeTask._(
      {required this.G__typename,
      required this.id,
      required this.state,
      required this.currentStage})
      : super._();
  @override
  GCompleteTaskData_completeTask rebuild(
          void Function(GCompleteTaskData_completeTaskBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCompleteTaskData_completeTaskBuilder toBuilder() =>
      GCompleteTaskData_completeTaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCompleteTaskData_completeTask &&
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
    return (newBuiltValueToStringHelper(r'GCompleteTaskData_completeTask')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('state', state)
          ..add('currentStage', currentStage))
        .toString();
  }
}

class GCompleteTaskData_completeTaskBuilder
    implements
        Builder<GCompleteTaskData_completeTask,
            GCompleteTaskData_completeTaskBuilder> {
  _$GCompleteTaskData_completeTask? _$v;

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

  GCompleteTaskData_completeTaskBuilder() {
    GCompleteTaskData_completeTask._initializeBuilder(this);
  }

  GCompleteTaskData_completeTaskBuilder get _$this {
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
  void replace(GCompleteTaskData_completeTask other) {
    _$v = other as _$GCompleteTaskData_completeTask;
  }

  @override
  void update(void Function(GCompleteTaskData_completeTaskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCompleteTaskData_completeTask build() => _build();

  _$GCompleteTaskData_completeTask _build() {
    final _$result = _$v ??
        _$GCompleteTaskData_completeTask._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GCompleteTaskData_completeTask', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GCompleteTaskData_completeTask', 'id'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GCompleteTaskData_completeTask', 'state'),
          currentStage: BuiltValueNullFieldError.checkNotNull(
              currentStage, r'GCompleteTaskData_completeTask', 'currentStage'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
