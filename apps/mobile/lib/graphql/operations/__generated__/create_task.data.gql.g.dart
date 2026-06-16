// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_task.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GCreateTaskData> _$gCreateTaskDataSerializer =
    _$GCreateTaskDataSerializer();
Serializer<GCreateTaskData_createTask> _$gCreateTaskDataCreateTaskSerializer =
    _$GCreateTaskData_createTaskSerializer();

class _$GCreateTaskDataSerializer
    implements StructuredSerializer<GCreateTaskData> {
  @override
  final Iterable<Type> types = const [GCreateTaskData, _$GCreateTaskData];
  @override
  final String wireName = 'GCreateTaskData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GCreateTaskData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'createTask',
      serializers.serialize(object.createTask,
          specifiedType: const FullType(GCreateTaskData_createTask)),
    ];

    return result;
  }

  @override
  GCreateTaskData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCreateTaskDataBuilder();

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
        case 'createTask':
          result.createTask.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GCreateTaskData_createTask))!
              as GCreateTaskData_createTask);
          break;
      }
    }

    return result.build();
  }
}

class _$GCreateTaskData_createTaskSerializer
    implements StructuredSerializer<GCreateTaskData_createTask> {
  @override
  final Iterable<Type> types = const [
    GCreateTaskData_createTask,
    _$GCreateTaskData_createTask
  ];
  @override
  final String wireName = 'GCreateTaskData_createTask';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GCreateTaskData_createTask object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'shortId',
      serializers.serialize(object.shortId, specifiedType: const FullType(int)),
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
      'state',
      serializers.serialize(object.state,
          specifiedType: const FullType(_i2.GTaskState)),
    ];

    return result;
  }

  @override
  GCreateTaskData_createTask deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCreateTaskData_createTaskBuilder();

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
        case 'shortId':
          result.shortId = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'state':
          result.state = serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTaskState))! as _i2.GTaskState;
          break;
      }
    }

    return result.build();
  }
}

class _$GCreateTaskData extends GCreateTaskData {
  @override
  final String G__typename;
  @override
  final GCreateTaskData_createTask createTask;

  factory _$GCreateTaskData([void Function(GCreateTaskDataBuilder)? updates]) =>
      (GCreateTaskDataBuilder()..update(updates))._build();

  _$GCreateTaskData._({required this.G__typename, required this.createTask})
      : super._();
  @override
  GCreateTaskData rebuild(void Function(GCreateTaskDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateTaskDataBuilder toBuilder() => GCreateTaskDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateTaskData &&
        G__typename == other.G__typename &&
        createTask == other.createTask;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, createTask.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCreateTaskData')
          ..add('G__typename', G__typename)
          ..add('createTask', createTask))
        .toString();
  }
}

class GCreateTaskDataBuilder
    implements Builder<GCreateTaskData, GCreateTaskDataBuilder> {
  _$GCreateTaskData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GCreateTaskData_createTaskBuilder? _createTask;
  GCreateTaskData_createTaskBuilder get createTask =>
      _$this._createTask ??= GCreateTaskData_createTaskBuilder();
  set createTask(GCreateTaskData_createTaskBuilder? createTask) =>
      _$this._createTask = createTask;

  GCreateTaskDataBuilder() {
    GCreateTaskData._initializeBuilder(this);
  }

  GCreateTaskDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _createTask = $v.createTask.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCreateTaskData other) {
    _$v = other as _$GCreateTaskData;
  }

  @override
  void update(void Function(GCreateTaskDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateTaskData build() => _build();

  _$GCreateTaskData _build() {
    _$GCreateTaskData _$result;
    try {
      _$result = _$v ??
          _$GCreateTaskData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GCreateTaskData', 'G__typename'),
            createTask: createTask.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createTask';
        createTask.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GCreateTaskData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GCreateTaskData_createTask extends GCreateTaskData_createTask {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final int shortId;
  @override
  final String title;
  @override
  final _i2.GTaskState state;

  factory _$GCreateTaskData_createTask(
          [void Function(GCreateTaskData_createTaskBuilder)? updates]) =>
      (GCreateTaskData_createTaskBuilder()..update(updates))._build();

  _$GCreateTaskData_createTask._(
      {required this.G__typename,
      required this.id,
      required this.shortId,
      required this.title,
      required this.state})
      : super._();
  @override
  GCreateTaskData_createTask rebuild(
          void Function(GCreateTaskData_createTaskBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateTaskData_createTaskBuilder toBuilder() =>
      GCreateTaskData_createTaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateTaskData_createTask &&
        G__typename == other.G__typename &&
        id == other.id &&
        shortId == other.shortId &&
        title == other.title &&
        state == other.state;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, shortId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCreateTaskData_createTask')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('shortId', shortId)
          ..add('title', title)
          ..add('state', state))
        .toString();
  }
}

class GCreateTaskData_createTaskBuilder
    implements
        Builder<GCreateTaskData_createTask, GCreateTaskData_createTaskBuilder> {
  _$GCreateTaskData_createTask? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _shortId;
  int? get shortId => _$this._shortId;
  set shortId(int? shortId) => _$this._shortId = shortId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  _i2.GTaskState? _state;
  _i2.GTaskState? get state => _$this._state;
  set state(_i2.GTaskState? state) => _$this._state = state;

  GCreateTaskData_createTaskBuilder() {
    GCreateTaskData_createTask._initializeBuilder(this);
  }

  GCreateTaskData_createTaskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _shortId = $v.shortId;
      _title = $v.title;
      _state = $v.state;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCreateTaskData_createTask other) {
    _$v = other as _$GCreateTaskData_createTask;
  }

  @override
  void update(void Function(GCreateTaskData_createTaskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateTaskData_createTask build() => _build();

  _$GCreateTaskData_createTask _build() {
    final _$result = _$v ??
        _$GCreateTaskData_createTask._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GCreateTaskData_createTask', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GCreateTaskData_createTask', 'id'),
          shortId: BuiltValueNullFieldError.checkNotNull(
              shortId, r'GCreateTaskData_createTask', 'shortId'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GCreateTaskData_createTask', 'title'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GCreateTaskData_createTask', 'state'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
