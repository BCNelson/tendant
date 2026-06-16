// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_detail.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GTaskDetailData> _$gTaskDetailDataSerializer =
    _$GTaskDetailDataSerializer();
Serializer<GTaskDetailData_task> _$gTaskDetailDataTaskSerializer =
    _$GTaskDetailData_taskSerializer();
Serializer<GTaskDetailData_task_stageSlots>
    _$gTaskDetailDataTaskStageSlotsSerializer =
    _$GTaskDetailData_task_stageSlotsSerializer();
Serializer<GTaskDetailData_task_stageSlots_occupant>
    _$gTaskDetailDataTaskStageSlotsOccupantSerializer =
    _$GTaskDetailData_task_stageSlots_occupantSerializer();
Serializer<GTaskDetailData_task_activity>
    _$gTaskDetailDataTaskActivitySerializer =
    _$GTaskDetailData_task_activitySerializer();

class _$GTaskDetailDataSerializer
    implements StructuredSerializer<GTaskDetailData> {
  @override
  final Iterable<Type> types = const [GTaskDetailData, _$GTaskDetailData];
  @override
  final String wireName = 'GTaskDetailData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GTaskDetailData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.task;
    if (value != null) {
      result
        ..add('task')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GTaskDetailData_task)));
    }
    return result;
  }

  @override
  GTaskDetailData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskDetailDataBuilder();

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
        case 'task':
          result.task.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GTaskDetailData_task))!
              as GTaskDetailData_task);
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskDetailData_taskSerializer
    implements StructuredSerializer<GTaskDetailData_task> {
  @override
  final Iterable<Type> types = const [
    GTaskDetailData_task,
    _$GTaskDetailData_task
  ];
  @override
  final String wireName = 'GTaskDetailData_task';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskDetailData_task object,
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
      'currentStage',
      serializers.serialize(object.currentStage,
          specifiedType: const FullType(_i2.GChainStage)),
      'autonomy',
      serializers.serialize(object.autonomy,
          specifiedType: const FullType(_i2.GAutonomyLevel)),
      'priority',
      serializers.serialize(object.priority,
          specifiedType: const FullType(_i2.GTaskPriority)),
      'stageSlots',
      serializers.serialize(object.stageSlots,
          specifiedType: const FullType(BuiltList,
              const [const FullType(GTaskDetailData_task_stageSlots)])),
      'activity',
      serializers.serialize(object.activity,
          specifiedType: const FullType(BuiltList,
              const [const FullType(GTaskDetailData_task_activity)])),
    ];
    Object? value;
    value = object.description;
    if (value != null) {
      result
        ..add('description')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.dueAt;
    if (value != null) {
      result
        ..add('dueAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    value = object.findings;
    if (value != null) {
      result
        ..add('findings')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i3.JsonObject)));
    }
    return result;
  }

  @override
  GTaskDetailData_task deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskDetailData_taskBuilder();

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
        case 'autonomy':
          result.autonomy = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GAutonomyLevel))!
              as _i2.GAutonomyLevel;
          break;
        case 'priority':
          result.priority = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GTaskPriority))!
              as _i2.GTaskPriority;
          break;
        case 'dueAt':
          result.dueAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'findings':
          result.findings = serializers.deserialize(value,
              specifiedType: const FullType(_i3.JsonObject)) as _i3.JsonObject?;
          break;
        case 'stageSlots':
          result.stageSlots.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GTaskDetailData_task_stageSlots)
              ]))! as BuiltList<Object?>);
          break;
        case 'activity':
          result.activity.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GTaskDetailData_task_activity)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskDetailData_task_stageSlotsSerializer
    implements StructuredSerializer<GTaskDetailData_task_stageSlots> {
  @override
  final Iterable<Type> types = const [
    GTaskDetailData_task_stageSlots,
    _$GTaskDetailData_task_stageSlots
  ];
  @override
  final String wireName = 'GTaskDetailData_task_stageSlots';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskDetailData_task_stageSlots object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'stage',
      serializers.serialize(object.stage,
          specifiedType: const FullType(_i2.GAgentStage)),
      'isHuman',
      serializers.serialize(object.isHuman,
          specifiedType: const FullType(bool)),
    ];
    Object? value;
    value = object.occupant;
    if (value != null) {
      result
        ..add('occupant')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(GTaskDetailData_task_stageSlots_occupant)));
    }
    return result;
  }

  @override
  GTaskDetailData_task_stageSlots deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskDetailData_task_stageSlotsBuilder();

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
        case 'stage':
          result.stage = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GAgentStage))!
              as _i2.GAgentStage;
          break;
        case 'isHuman':
          result.isHuman = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'occupant':
          result.occupant.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GTaskDetailData_task_stageSlots_occupant))!
              as GTaskDetailData_task_stageSlots_occupant);
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskDetailData_task_stageSlots_occupantSerializer
    implements StructuredSerializer<GTaskDetailData_task_stageSlots_occupant> {
  @override
  final Iterable<Type> types = const [
    GTaskDetailData_task_stageSlots_occupant,
    _$GTaskDetailData_task_stageSlots_occupant
  ];
  @override
  final String wireName = 'GTaskDetailData_task_stageSlots_occupant';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskDetailData_task_stageSlots_occupant object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.model;
    if (value != null) {
      result
        ..add('model')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GTaskDetailData_task_stageSlots_occupant deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskDetailData_task_stageSlots_occupantBuilder();

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
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'model':
          result.model = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskDetailData_task_activitySerializer
    implements StructuredSerializer<GTaskDetailData_task_activity> {
  @override
  final Iterable<Type> types = const [
    GTaskDetailData_task_activity,
    _$GTaskDetailData_task_activity
  ];
  @override
  final String wireName = 'GTaskDetailData_task_activity';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskDetailData_task_activity object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'kind',
      serializers.serialize(object.kind, specifiedType: const FullType(String)),
      'at',
      serializers.serialize(object.at,
          specifiedType: const FullType(_i2.GTime)),
      'actor',
      serializers.serialize(object.actor,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.inReplyTo;
    if (value != null) {
      result
        ..add('inReplyTo')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.detail;
    if (value != null) {
      result
        ..add('detail')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i3.JsonObject)));
    }
    return result;
  }

  @override
  GTaskDetailData_task_activity deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskDetailData_task_activityBuilder();

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
        case 'kind':
          result.kind = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'at':
          result.at.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'actor':
          result.actor = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'inReplyTo':
          result.inReplyTo = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'detail':
          result.detail = serializers.deserialize(value,
              specifiedType: const FullType(_i3.JsonObject)) as _i3.JsonObject?;
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskDetailData extends GTaskDetailData {
  @override
  final String G__typename;
  @override
  final GTaskDetailData_task? task;

  factory _$GTaskDetailData([void Function(GTaskDetailDataBuilder)? updates]) =>
      (GTaskDetailDataBuilder()..update(updates))._build();

  _$GTaskDetailData._({required this.G__typename, this.task}) : super._();
  @override
  GTaskDetailData rebuild(void Function(GTaskDetailDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskDetailDataBuilder toBuilder() => GTaskDetailDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskDetailData &&
        G__typename == other.G__typename &&
        task == other.task;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, task.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTaskDetailData')
          ..add('G__typename', G__typename)
          ..add('task', task))
        .toString();
  }
}

class GTaskDetailDataBuilder
    implements Builder<GTaskDetailData, GTaskDetailDataBuilder> {
  _$GTaskDetailData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GTaskDetailData_taskBuilder? _task;
  GTaskDetailData_taskBuilder get task =>
      _$this._task ??= GTaskDetailData_taskBuilder();
  set task(GTaskDetailData_taskBuilder? task) => _$this._task = task;

  GTaskDetailDataBuilder() {
    GTaskDetailData._initializeBuilder(this);
  }

  GTaskDetailDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _task = $v.task?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskDetailData other) {
    _$v = other as _$GTaskDetailData;
  }

  @override
  void update(void Function(GTaskDetailDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskDetailData build() => _build();

  _$GTaskDetailData _build() {
    _$GTaskDetailData _$result;
    try {
      _$result = _$v ??
          _$GTaskDetailData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GTaskDetailData', 'G__typename'),
            task: _task?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'task';
        _task?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GTaskDetailData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTaskDetailData_task extends GTaskDetailData_task {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final int shortId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final _i2.GTaskState state;
  @override
  final _i2.GChainStage currentStage;
  @override
  final _i2.GAutonomyLevel autonomy;
  @override
  final _i2.GTaskPriority priority;
  @override
  final _i2.GTime? dueAt;
  @override
  final _i3.JsonObject? findings;
  @override
  final BuiltList<GTaskDetailData_task_stageSlots> stageSlots;
  @override
  final BuiltList<GTaskDetailData_task_activity> activity;

  factory _$GTaskDetailData_task(
          [void Function(GTaskDetailData_taskBuilder)? updates]) =>
      (GTaskDetailData_taskBuilder()..update(updates))._build();

  _$GTaskDetailData_task._(
      {required this.G__typename,
      required this.id,
      required this.shortId,
      required this.title,
      this.description,
      required this.state,
      required this.currentStage,
      required this.autonomy,
      required this.priority,
      this.dueAt,
      this.findings,
      required this.stageSlots,
      required this.activity})
      : super._();
  @override
  GTaskDetailData_task rebuild(
          void Function(GTaskDetailData_taskBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskDetailData_taskBuilder toBuilder() =>
      GTaskDetailData_taskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskDetailData_task &&
        G__typename == other.G__typename &&
        id == other.id &&
        shortId == other.shortId &&
        title == other.title &&
        description == other.description &&
        state == other.state &&
        currentStage == other.currentStage &&
        autonomy == other.autonomy &&
        priority == other.priority &&
        dueAt == other.dueAt &&
        findings == other.findings &&
        stageSlots == other.stageSlots &&
        activity == other.activity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, shortId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, currentStage.hashCode);
    _$hash = $jc(_$hash, autonomy.hashCode);
    _$hash = $jc(_$hash, priority.hashCode);
    _$hash = $jc(_$hash, dueAt.hashCode);
    _$hash = $jc(_$hash, findings.hashCode);
    _$hash = $jc(_$hash, stageSlots.hashCode);
    _$hash = $jc(_$hash, activity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTaskDetailData_task')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('shortId', shortId)
          ..add('title', title)
          ..add('description', description)
          ..add('state', state)
          ..add('currentStage', currentStage)
          ..add('autonomy', autonomy)
          ..add('priority', priority)
          ..add('dueAt', dueAt)
          ..add('findings', findings)
          ..add('stageSlots', stageSlots)
          ..add('activity', activity))
        .toString();
  }
}

class GTaskDetailData_taskBuilder
    implements Builder<GTaskDetailData_task, GTaskDetailData_taskBuilder> {
  _$GTaskDetailData_task? _$v;

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

  _i2.GAutonomyLevel? _autonomy;
  _i2.GAutonomyLevel? get autonomy => _$this._autonomy;
  set autonomy(_i2.GAutonomyLevel? autonomy) => _$this._autonomy = autonomy;

  _i2.GTaskPriority? _priority;
  _i2.GTaskPriority? get priority => _$this._priority;
  set priority(_i2.GTaskPriority? priority) => _$this._priority = priority;

  _i2.GTimeBuilder? _dueAt;
  _i2.GTimeBuilder get dueAt => _$this._dueAt ??= _i2.GTimeBuilder();
  set dueAt(_i2.GTimeBuilder? dueAt) => _$this._dueAt = dueAt;

  _i3.JsonObject? _findings;
  _i3.JsonObject? get findings => _$this._findings;
  set findings(_i3.JsonObject? findings) => _$this._findings = findings;

  ListBuilder<GTaskDetailData_task_stageSlots>? _stageSlots;
  ListBuilder<GTaskDetailData_task_stageSlots> get stageSlots =>
      _$this._stageSlots ??= ListBuilder<GTaskDetailData_task_stageSlots>();
  set stageSlots(ListBuilder<GTaskDetailData_task_stageSlots>? stageSlots) =>
      _$this._stageSlots = stageSlots;

  ListBuilder<GTaskDetailData_task_activity>? _activity;
  ListBuilder<GTaskDetailData_task_activity> get activity =>
      _$this._activity ??= ListBuilder<GTaskDetailData_task_activity>();
  set activity(ListBuilder<GTaskDetailData_task_activity>? activity) =>
      _$this._activity = activity;

  GTaskDetailData_taskBuilder() {
    GTaskDetailData_task._initializeBuilder(this);
  }

  GTaskDetailData_taskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _shortId = $v.shortId;
      _title = $v.title;
      _description = $v.description;
      _state = $v.state;
      _currentStage = $v.currentStage;
      _autonomy = $v.autonomy;
      _priority = $v.priority;
      _dueAt = $v.dueAt?.toBuilder();
      _findings = $v.findings;
      _stageSlots = $v.stageSlots.toBuilder();
      _activity = $v.activity.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskDetailData_task other) {
    _$v = other as _$GTaskDetailData_task;
  }

  @override
  void update(void Function(GTaskDetailData_taskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskDetailData_task build() => _build();

  _$GTaskDetailData_task _build() {
    _$GTaskDetailData_task _$result;
    try {
      _$result = _$v ??
          _$GTaskDetailData_task._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GTaskDetailData_task', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GTaskDetailData_task', 'id'),
            shortId: BuiltValueNullFieldError.checkNotNull(
                shortId, r'GTaskDetailData_task', 'shortId'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'GTaskDetailData_task', 'title'),
            description: description,
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'GTaskDetailData_task', 'state'),
            currentStage: BuiltValueNullFieldError.checkNotNull(
                currentStage, r'GTaskDetailData_task', 'currentStage'),
            autonomy: BuiltValueNullFieldError.checkNotNull(
                autonomy, r'GTaskDetailData_task', 'autonomy'),
            priority: BuiltValueNullFieldError.checkNotNull(
                priority, r'GTaskDetailData_task', 'priority'),
            dueAt: _dueAt?.build(),
            findings: findings,
            stageSlots: stageSlots.build(),
            activity: activity.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dueAt';
        _dueAt?.build();

        _$failedField = 'stageSlots';
        stageSlots.build();
        _$failedField = 'activity';
        activity.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GTaskDetailData_task', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTaskDetailData_task_stageSlots
    extends GTaskDetailData_task_stageSlots {
  @override
  final String G__typename;
  @override
  final _i2.GAgentStage stage;
  @override
  final bool isHuman;
  @override
  final GTaskDetailData_task_stageSlots_occupant? occupant;

  factory _$GTaskDetailData_task_stageSlots(
          [void Function(GTaskDetailData_task_stageSlotsBuilder)? updates]) =>
      (GTaskDetailData_task_stageSlotsBuilder()..update(updates))._build();

  _$GTaskDetailData_task_stageSlots._(
      {required this.G__typename,
      required this.stage,
      required this.isHuman,
      this.occupant})
      : super._();
  @override
  GTaskDetailData_task_stageSlots rebuild(
          void Function(GTaskDetailData_task_stageSlotsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskDetailData_task_stageSlotsBuilder toBuilder() =>
      GTaskDetailData_task_stageSlotsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskDetailData_task_stageSlots &&
        G__typename == other.G__typename &&
        stage == other.stage &&
        isHuman == other.isHuman &&
        occupant == other.occupant;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jc(_$hash, isHuman.hashCode);
    _$hash = $jc(_$hash, occupant.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTaskDetailData_task_stageSlots')
          ..add('G__typename', G__typename)
          ..add('stage', stage)
          ..add('isHuman', isHuman)
          ..add('occupant', occupant))
        .toString();
  }
}

class GTaskDetailData_task_stageSlotsBuilder
    implements
        Builder<GTaskDetailData_task_stageSlots,
            GTaskDetailData_task_stageSlotsBuilder> {
  _$GTaskDetailData_task_stageSlots? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  _i2.GAgentStage? _stage;
  _i2.GAgentStage? get stage => _$this._stage;
  set stage(_i2.GAgentStage? stage) => _$this._stage = stage;

  bool? _isHuman;
  bool? get isHuman => _$this._isHuman;
  set isHuman(bool? isHuman) => _$this._isHuman = isHuman;

  GTaskDetailData_task_stageSlots_occupantBuilder? _occupant;
  GTaskDetailData_task_stageSlots_occupantBuilder get occupant =>
      _$this._occupant ??= GTaskDetailData_task_stageSlots_occupantBuilder();
  set occupant(GTaskDetailData_task_stageSlots_occupantBuilder? occupant) =>
      _$this._occupant = occupant;

  GTaskDetailData_task_stageSlotsBuilder() {
    GTaskDetailData_task_stageSlots._initializeBuilder(this);
  }

  GTaskDetailData_task_stageSlotsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _stage = $v.stage;
      _isHuman = $v.isHuman;
      _occupant = $v.occupant?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskDetailData_task_stageSlots other) {
    _$v = other as _$GTaskDetailData_task_stageSlots;
  }

  @override
  void update(void Function(GTaskDetailData_task_stageSlotsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskDetailData_task_stageSlots build() => _build();

  _$GTaskDetailData_task_stageSlots _build() {
    _$GTaskDetailData_task_stageSlots _$result;
    try {
      _$result = _$v ??
          _$GTaskDetailData_task_stageSlots._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GTaskDetailData_task_stageSlots', 'G__typename'),
            stage: BuiltValueNullFieldError.checkNotNull(
                stage, r'GTaskDetailData_task_stageSlots', 'stage'),
            isHuman: BuiltValueNullFieldError.checkNotNull(
                isHuman, r'GTaskDetailData_task_stageSlots', 'isHuman'),
            occupant: _occupant?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'occupant';
        _occupant?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GTaskDetailData_task_stageSlots', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTaskDetailData_task_stageSlots_occupant
    extends GTaskDetailData_task_stageSlots_occupant {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String name;
  @override
  final String? model;

  factory _$GTaskDetailData_task_stageSlots_occupant(
          [void Function(GTaskDetailData_task_stageSlots_occupantBuilder)?
              updates]) =>
      (GTaskDetailData_task_stageSlots_occupantBuilder()..update(updates))
          ._build();

  _$GTaskDetailData_task_stageSlots_occupant._(
      {required this.G__typename,
      required this.id,
      required this.name,
      this.model})
      : super._();
  @override
  GTaskDetailData_task_stageSlots_occupant rebuild(
          void Function(GTaskDetailData_task_stageSlots_occupantBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskDetailData_task_stageSlots_occupantBuilder toBuilder() =>
      GTaskDetailData_task_stageSlots_occupantBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskDetailData_task_stageSlots_occupant &&
        G__typename == other.G__typename &&
        id == other.id &&
        name == other.name &&
        model == other.model;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, model.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GTaskDetailData_task_stageSlots_occupant')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('name', name)
          ..add('model', model))
        .toString();
  }
}

class GTaskDetailData_task_stageSlots_occupantBuilder
    implements
        Builder<GTaskDetailData_task_stageSlots_occupant,
            GTaskDetailData_task_stageSlots_occupantBuilder> {
  _$GTaskDetailData_task_stageSlots_occupant? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _model;
  String? get model => _$this._model;
  set model(String? model) => _$this._model = model;

  GTaskDetailData_task_stageSlots_occupantBuilder() {
    GTaskDetailData_task_stageSlots_occupant._initializeBuilder(this);
  }

  GTaskDetailData_task_stageSlots_occupantBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _name = $v.name;
      _model = $v.model;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskDetailData_task_stageSlots_occupant other) {
    _$v = other as _$GTaskDetailData_task_stageSlots_occupant;
  }

  @override
  void update(
      void Function(GTaskDetailData_task_stageSlots_occupantBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskDetailData_task_stageSlots_occupant build() => _build();

  _$GTaskDetailData_task_stageSlots_occupant _build() {
    final _$result = _$v ??
        _$GTaskDetailData_task_stageSlots_occupant._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GTaskDetailData_task_stageSlots_occupant', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTaskDetailData_task_stageSlots_occupant', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GTaskDetailData_task_stageSlots_occupant', 'name'),
          model: model,
        );
    replace(_$result);
    return _$result;
  }
}

class _$GTaskDetailData_task_activity extends GTaskDetailData_task_activity {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String kind;
  @override
  final _i2.GTime at;
  @override
  final String actor;
  @override
  final String? inReplyTo;
  @override
  final _i3.JsonObject? detail;

  factory _$GTaskDetailData_task_activity(
          [void Function(GTaskDetailData_task_activityBuilder)? updates]) =>
      (GTaskDetailData_task_activityBuilder()..update(updates))._build();

  _$GTaskDetailData_task_activity._(
      {required this.G__typename,
      required this.id,
      required this.kind,
      required this.at,
      required this.actor,
      this.inReplyTo,
      this.detail})
      : super._();
  @override
  GTaskDetailData_task_activity rebuild(
          void Function(GTaskDetailData_task_activityBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskDetailData_task_activityBuilder toBuilder() =>
      GTaskDetailData_task_activityBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskDetailData_task_activity &&
        G__typename == other.G__typename &&
        id == other.id &&
        kind == other.kind &&
        at == other.at &&
        actor == other.actor &&
        inReplyTo == other.inReplyTo &&
        detail == other.detail;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, at.hashCode);
    _$hash = $jc(_$hash, actor.hashCode);
    _$hash = $jc(_$hash, inReplyTo.hashCode);
    _$hash = $jc(_$hash, detail.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTaskDetailData_task_activity')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('kind', kind)
          ..add('at', at)
          ..add('actor', actor)
          ..add('inReplyTo', inReplyTo)
          ..add('detail', detail))
        .toString();
  }
}

class GTaskDetailData_task_activityBuilder
    implements
        Builder<GTaskDetailData_task_activity,
            GTaskDetailData_task_activityBuilder> {
  _$GTaskDetailData_task_activity? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _kind;
  String? get kind => _$this._kind;
  set kind(String? kind) => _$this._kind = kind;

  _i2.GTimeBuilder? _at;
  _i2.GTimeBuilder get at => _$this._at ??= _i2.GTimeBuilder();
  set at(_i2.GTimeBuilder? at) => _$this._at = at;

  String? _actor;
  String? get actor => _$this._actor;
  set actor(String? actor) => _$this._actor = actor;

  String? _inReplyTo;
  String? get inReplyTo => _$this._inReplyTo;
  set inReplyTo(String? inReplyTo) => _$this._inReplyTo = inReplyTo;

  _i3.JsonObject? _detail;
  _i3.JsonObject? get detail => _$this._detail;
  set detail(_i3.JsonObject? detail) => _$this._detail = detail;

  GTaskDetailData_task_activityBuilder() {
    GTaskDetailData_task_activity._initializeBuilder(this);
  }

  GTaskDetailData_task_activityBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _kind = $v.kind;
      _at = $v.at.toBuilder();
      _actor = $v.actor;
      _inReplyTo = $v.inReplyTo;
      _detail = $v.detail;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskDetailData_task_activity other) {
    _$v = other as _$GTaskDetailData_task_activity;
  }

  @override
  void update(void Function(GTaskDetailData_task_activityBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskDetailData_task_activity build() => _build();

  _$GTaskDetailData_task_activity _build() {
    _$GTaskDetailData_task_activity _$result;
    try {
      _$result = _$v ??
          _$GTaskDetailData_task_activity._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GTaskDetailData_task_activity', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GTaskDetailData_task_activity', 'id'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'GTaskDetailData_task_activity', 'kind'),
            at: at.build(),
            actor: BuiltValueNullFieldError.checkNotNull(
                actor, r'GTaskDetailData_task_activity', 'actor'),
            inReplyTo: inReplyTo,
            detail: detail,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'at';
        at.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GTaskDetailData_task_activity', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
