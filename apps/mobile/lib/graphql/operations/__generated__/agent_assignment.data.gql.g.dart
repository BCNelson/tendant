// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_assignment.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GAgentAssignmentData> _$gAgentAssignmentDataSerializer =
    _$GAgentAssignmentDataSerializer();
Serializer<GAgentAssignmentData_agentAssignment>
    _$gAgentAssignmentDataAgentAssignmentSerializer =
    _$GAgentAssignmentData_agentAssignmentSerializer();
Serializer<GAgentAssignmentData_agentAssignment_task>
    _$gAgentAssignmentDataAgentAssignmentTaskSerializer =
    _$GAgentAssignmentData_agentAssignment_taskSerializer();

class _$GAgentAssignmentDataSerializer
    implements StructuredSerializer<GAgentAssignmentData> {
  @override
  final Iterable<Type> types = const [
    GAgentAssignmentData,
    _$GAgentAssignmentData
  ];
  @override
  final String wireName = 'GAgentAssignmentData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAgentAssignmentData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.agentAssignment;
    if (value != null) {
      result
        ..add('agentAssignment')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(GAgentAssignmentData_agentAssignment)));
    }
    return result;
  }

  @override
  GAgentAssignmentData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAgentAssignmentDataBuilder();

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
        case 'agentAssignment':
          result.agentAssignment.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GAgentAssignmentData_agentAssignment))!
              as GAgentAssignmentData_agentAssignment);
          break;
      }
    }

    return result.build();
  }
}

class _$GAgentAssignmentData_agentAssignmentSerializer
    implements StructuredSerializer<GAgentAssignmentData_agentAssignment> {
  @override
  final Iterable<Type> types = const [
    GAgentAssignmentData_agentAssignment,
    _$GAgentAssignmentData_agentAssignment
  ];
  @override
  final String wireName = 'GAgentAssignmentData_agentAssignment';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAgentAssignmentData_agentAssignment object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'stage',
      serializers.serialize(object.stage,
          specifiedType: const FullType(_i2.GChainStage)),
      'ask',
      serializers.serialize(object.ask, specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i2.GTime)),
      'task',
      serializers.serialize(object.task,
          specifiedType:
              const FullType(GAgentAssignmentData_agentAssignment_task)),
    ];
    Object? value;
    value = object.gatheredContext;
    if (value != null) {
      result
        ..add('gatheredContext')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i3.JsonObject)));
    }
    return result;
  }

  @override
  GAgentAssignmentData_agentAssignment deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAgentAssignmentData_agentAssignmentBuilder();

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
        case 'stage':
          result.stage = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GChainStage))!
              as _i2.GChainStage;
          break;
        case 'ask':
          result.ask = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'gatheredContext':
          result.gatheredContext = serializers.deserialize(value,
              specifiedType: const FullType(_i3.JsonObject)) as _i3.JsonObject?;
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'task':
          result.task.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GAgentAssignmentData_agentAssignment_task))!
              as GAgentAssignmentData_agentAssignment_task);
          break;
      }
    }

    return result.build();
  }
}

class _$GAgentAssignmentData_agentAssignment_taskSerializer
    implements StructuredSerializer<GAgentAssignmentData_agentAssignment_task> {
  @override
  final Iterable<Type> types = const [
    GAgentAssignmentData_agentAssignment_task,
    _$GAgentAssignmentData_agentAssignment_task
  ];
  @override
  final String wireName = 'GAgentAssignmentData_agentAssignment_task';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAgentAssignmentData_agentAssignment_task object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
      'state',
      serializers.serialize(object.state,
          specifiedType: const FullType(_i2.GTaskState)),
      'currentStage',
      serializers.serialize(object.currentStage,
          specifiedType: const FullType(_i2.GChainStage)),
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
  GAgentAssignmentData_agentAssignment_task deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAgentAssignmentData_agentAssignment_taskBuilder();

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
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'description':
          result.description = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
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

class _$GAgentAssignmentData extends GAgentAssignmentData {
  @override
  final String G__typename;
  @override
  final GAgentAssignmentData_agentAssignment? agentAssignment;

  factory _$GAgentAssignmentData(
          [void Function(GAgentAssignmentDataBuilder)? updates]) =>
      (GAgentAssignmentDataBuilder()..update(updates))._build();

  _$GAgentAssignmentData._({required this.G__typename, this.agentAssignment})
      : super._();
  @override
  GAgentAssignmentData rebuild(
          void Function(GAgentAssignmentDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAgentAssignmentDataBuilder toBuilder() =>
      GAgentAssignmentDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAgentAssignmentData &&
        G__typename == other.G__typename &&
        agentAssignment == other.agentAssignment;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, agentAssignment.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAgentAssignmentData')
          ..add('G__typename', G__typename)
          ..add('agentAssignment', agentAssignment))
        .toString();
  }
}

class GAgentAssignmentDataBuilder
    implements Builder<GAgentAssignmentData, GAgentAssignmentDataBuilder> {
  _$GAgentAssignmentData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GAgentAssignmentData_agentAssignmentBuilder? _agentAssignment;
  GAgentAssignmentData_agentAssignmentBuilder get agentAssignment =>
      _$this._agentAssignment ??= GAgentAssignmentData_agentAssignmentBuilder();
  set agentAssignment(
          GAgentAssignmentData_agentAssignmentBuilder? agentAssignment) =>
      _$this._agentAssignment = agentAssignment;

  GAgentAssignmentDataBuilder() {
    GAgentAssignmentData._initializeBuilder(this);
  }

  GAgentAssignmentDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _agentAssignment = $v.agentAssignment?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAgentAssignmentData other) {
    _$v = other as _$GAgentAssignmentData;
  }

  @override
  void update(void Function(GAgentAssignmentDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAgentAssignmentData build() => _build();

  _$GAgentAssignmentData _build() {
    _$GAgentAssignmentData _$result;
    try {
      _$result = _$v ??
          _$GAgentAssignmentData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GAgentAssignmentData', 'G__typename'),
            agentAssignment: _agentAssignment?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'agentAssignment';
        _agentAssignment?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GAgentAssignmentData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GAgentAssignmentData_agentAssignment
    extends GAgentAssignmentData_agentAssignment {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GChainStage stage;
  @override
  final String ask;
  @override
  final _i3.JsonObject? gatheredContext;
  @override
  final _i2.GTime createdAt;
  @override
  final GAgentAssignmentData_agentAssignment_task task;

  factory _$GAgentAssignmentData_agentAssignment(
          [void Function(GAgentAssignmentData_agentAssignmentBuilder)?
              updates]) =>
      (GAgentAssignmentData_agentAssignmentBuilder()..update(updates))._build();

  _$GAgentAssignmentData_agentAssignment._(
      {required this.G__typename,
      required this.id,
      required this.stage,
      required this.ask,
      this.gatheredContext,
      required this.createdAt,
      required this.task})
      : super._();
  @override
  GAgentAssignmentData_agentAssignment rebuild(
          void Function(GAgentAssignmentData_agentAssignmentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAgentAssignmentData_agentAssignmentBuilder toBuilder() =>
      GAgentAssignmentData_agentAssignmentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAgentAssignmentData_agentAssignment &&
        G__typename == other.G__typename &&
        id == other.id &&
        stage == other.stage &&
        ask == other.ask &&
        gatheredContext == other.gatheredContext &&
        createdAt == other.createdAt &&
        task == other.task;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jc(_$hash, ask.hashCode);
    _$hash = $jc(_$hash, gatheredContext.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, task.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAgentAssignmentData_agentAssignment')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('stage', stage)
          ..add('ask', ask)
          ..add('gatheredContext', gatheredContext)
          ..add('createdAt', createdAt)
          ..add('task', task))
        .toString();
  }
}

class GAgentAssignmentData_agentAssignmentBuilder
    implements
        Builder<GAgentAssignmentData_agentAssignment,
            GAgentAssignmentData_agentAssignmentBuilder> {
  _$GAgentAssignmentData_agentAssignment? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GChainStage? _stage;
  _i2.GChainStage? get stage => _$this._stage;
  set stage(_i2.GChainStage? stage) => _$this._stage = stage;

  String? _ask;
  String? get ask => _$this._ask;
  set ask(String? ask) => _$this._ask = ask;

  _i3.JsonObject? _gatheredContext;
  _i3.JsonObject? get gatheredContext => _$this._gatheredContext;
  set gatheredContext(_i3.JsonObject? gatheredContext) =>
      _$this._gatheredContext = gatheredContext;

  _i2.GTimeBuilder? _createdAt;
  _i2.GTimeBuilder get createdAt => _$this._createdAt ??= _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GAgentAssignmentData_agentAssignment_taskBuilder? _task;
  GAgentAssignmentData_agentAssignment_taskBuilder get task =>
      _$this._task ??= GAgentAssignmentData_agentAssignment_taskBuilder();
  set task(GAgentAssignmentData_agentAssignment_taskBuilder? task) =>
      _$this._task = task;

  GAgentAssignmentData_agentAssignmentBuilder() {
    GAgentAssignmentData_agentAssignment._initializeBuilder(this);
  }

  GAgentAssignmentData_agentAssignmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _stage = $v.stage;
      _ask = $v.ask;
      _gatheredContext = $v.gatheredContext;
      _createdAt = $v.createdAt.toBuilder();
      _task = $v.task.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAgentAssignmentData_agentAssignment other) {
    _$v = other as _$GAgentAssignmentData_agentAssignment;
  }

  @override
  void update(
      void Function(GAgentAssignmentData_agentAssignmentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAgentAssignmentData_agentAssignment build() => _build();

  _$GAgentAssignmentData_agentAssignment _build() {
    _$GAgentAssignmentData_agentAssignment _$result;
    try {
      _$result = _$v ??
          _$GAgentAssignmentData_agentAssignment._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GAgentAssignmentData_agentAssignment', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GAgentAssignmentData_agentAssignment', 'id'),
            stage: BuiltValueNullFieldError.checkNotNull(
                stage, r'GAgentAssignmentData_agentAssignment', 'stage'),
            ask: BuiltValueNullFieldError.checkNotNull(
                ask, r'GAgentAssignmentData_agentAssignment', 'ask'),
            gatheredContext: gatheredContext,
            createdAt: createdAt.build(),
            task: task.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
        _$failedField = 'task';
        task.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GAgentAssignmentData_agentAssignment',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GAgentAssignmentData_agentAssignment_task
    extends GAgentAssignmentData_agentAssignment_task {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final _i2.GTaskState state;
  @override
  final _i2.GChainStage currentStage;

  factory _$GAgentAssignmentData_agentAssignment_task(
          [void Function(GAgentAssignmentData_agentAssignment_taskBuilder)?
              updates]) =>
      (GAgentAssignmentData_agentAssignment_taskBuilder()..update(updates))
          ._build();

  _$GAgentAssignmentData_agentAssignment_task._(
      {required this.G__typename,
      required this.id,
      required this.title,
      this.description,
      required this.state,
      required this.currentStage})
      : super._();
  @override
  GAgentAssignmentData_agentAssignment_task rebuild(
          void Function(GAgentAssignmentData_agentAssignment_taskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAgentAssignmentData_agentAssignment_taskBuilder toBuilder() =>
      GAgentAssignmentData_agentAssignment_taskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAgentAssignmentData_agentAssignment_task &&
        G__typename == other.G__typename &&
        id == other.id &&
        title == other.title &&
        description == other.description &&
        state == other.state &&
        currentStage == other.currentStage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, currentStage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GAgentAssignmentData_agentAssignment_task')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('title', title)
          ..add('description', description)
          ..add('state', state)
          ..add('currentStage', currentStage))
        .toString();
  }
}

class GAgentAssignmentData_agentAssignment_taskBuilder
    implements
        Builder<GAgentAssignmentData_agentAssignment_task,
            GAgentAssignmentData_agentAssignment_taskBuilder> {
  _$GAgentAssignmentData_agentAssignment_task? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  _i2.GTaskState? _state;
  _i2.GTaskState? get state => _$this._state;
  set state(_i2.GTaskState? state) => _$this._state = state;

  _i2.GChainStage? _currentStage;
  _i2.GChainStage? get currentStage => _$this._currentStage;
  set currentStage(_i2.GChainStage? currentStage) =>
      _$this._currentStage = currentStage;

  GAgentAssignmentData_agentAssignment_taskBuilder() {
    GAgentAssignmentData_agentAssignment_task._initializeBuilder(this);
  }

  GAgentAssignmentData_agentAssignment_taskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _title = $v.title;
      _description = $v.description;
      _state = $v.state;
      _currentStage = $v.currentStage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAgentAssignmentData_agentAssignment_task other) {
    _$v = other as _$GAgentAssignmentData_agentAssignment_task;
  }

  @override
  void update(
      void Function(GAgentAssignmentData_agentAssignment_taskBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GAgentAssignmentData_agentAssignment_task build() => _build();

  _$GAgentAssignmentData_agentAssignment_task _build() {
    final _$result = _$v ??
        _$GAgentAssignmentData_agentAssignment_task._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GAgentAssignmentData_agentAssignment_task', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GAgentAssignmentData_agentAssignment_task', 'id'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GAgentAssignmentData_agentAssignment_task', 'title'),
          description: description,
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GAgentAssignmentData_agentAssignment_task', 'state'),
          currentStage: BuiltValueNullFieldError.checkNotNull(currentStage,
              r'GAgentAssignmentData_agentAssignment_task', 'currentStage'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
