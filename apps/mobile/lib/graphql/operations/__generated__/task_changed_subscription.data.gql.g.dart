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
Serializer<GTaskChangedData_taskChanged_openAssignment>
    _$gTaskChangedDataTaskChangedOpenAssignmentSerializer =
    _$GTaskChangedData_taskChanged_openAssignmentSerializer();
Serializer<GTaskChangedData_taskChanged_stageSlots>
    _$gTaskChangedDataTaskChangedStageSlotsSerializer =
    _$GTaskChangedData_taskChanged_stageSlotsSerializer();
Serializer<GTaskChangedData_taskChanged_stageSlots_occupant>
    _$gTaskChangedDataTaskChangedStageSlotsOccupantSerializer =
    _$GTaskChangedData_taskChanged_stageSlots_occupantSerializer();

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
              const [const FullType(GTaskChangedData_taskChanged_stageSlots)])),
    ];
    Object? value;
    value = object.dueAt;
    if (value != null) {
      result
        ..add('dueAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    value = object.openAssignment;
    if (value != null) {
      result
        ..add('openAssignment')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(GTaskChangedData_taskChanged_openAssignment)));
    }
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
        case 'openAssignment':
          result.openAssignment.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GTaskChangedData_taskChanged_openAssignment))!
              as GTaskChangedData_taskChanged_openAssignment);
          break;
        case 'stageSlots':
          result.stageSlots.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GTaskChangedData_taskChanged_stageSlots)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskChangedData_taskChanged_openAssignmentSerializer
    implements
        StructuredSerializer<GTaskChangedData_taskChanged_openAssignment> {
  @override
  final Iterable<Type> types = const [
    GTaskChangedData_taskChanged_openAssignment,
    _$GTaskChangedData_taskChanged_openAssignment
  ];
  @override
  final String wireName = 'GTaskChangedData_taskChanged_openAssignment';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GTaskChangedData_taskChanged_openAssignment object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GTaskChangedData_taskChanged_openAssignment deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskChangedData_taskChanged_openAssignmentBuilder();

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
      }
    }

    return result.build();
  }
}

class _$GTaskChangedData_taskChanged_stageSlotsSerializer
    implements StructuredSerializer<GTaskChangedData_taskChanged_stageSlots> {
  @override
  final Iterable<Type> types = const [
    GTaskChangedData_taskChanged_stageSlots,
    _$GTaskChangedData_taskChanged_stageSlots
  ];
  @override
  final String wireName = 'GTaskChangedData_taskChanged_stageSlots';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskChangedData_taskChanged_stageSlots object,
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
            specifiedType: const FullType(
                GTaskChangedData_taskChanged_stageSlots_occupant)));
    }
    return result;
  }

  @override
  GTaskChangedData_taskChanged_stageSlots deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskChangedData_taskChanged_stageSlotsBuilder();

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
                  specifiedType: const FullType(
                      GTaskChangedData_taskChanged_stageSlots_occupant))!
              as GTaskChangedData_taskChanged_stageSlots_occupant);
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskChangedData_taskChanged_stageSlots_occupantSerializer
    implements
        StructuredSerializer<GTaskChangedData_taskChanged_stageSlots_occupant> {
  @override
  final Iterable<Type> types = const [
    GTaskChangedData_taskChanged_stageSlots_occupant,
    _$GTaskChangedData_taskChanged_stageSlots_occupant
  ];
  @override
  final String wireName = 'GTaskChangedData_taskChanged_stageSlots_occupant';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GTaskChangedData_taskChanged_stageSlots_occupant object,
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
  GTaskChangedData_taskChanged_stageSlots_occupant deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskChangedData_taskChanged_stageSlots_occupantBuilder();

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
  final int shortId;
  @override
  final String title;
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
  final GTaskChangedData_taskChanged_openAssignment? openAssignment;
  @override
  final BuiltList<GTaskChangedData_taskChanged_stageSlots> stageSlots;

  factory _$GTaskChangedData_taskChanged(
          [void Function(GTaskChangedData_taskChangedBuilder)? updates]) =>
      (GTaskChangedData_taskChangedBuilder()..update(updates))._build();

  _$GTaskChangedData_taskChanged._(
      {required this.G__typename,
      required this.id,
      required this.shortId,
      required this.title,
      required this.state,
      required this.currentStage,
      required this.autonomy,
      required this.priority,
      this.dueAt,
      this.openAssignment,
      required this.stageSlots})
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
        shortId == other.shortId &&
        title == other.title &&
        state == other.state &&
        currentStage == other.currentStage &&
        autonomy == other.autonomy &&
        priority == other.priority &&
        dueAt == other.dueAt &&
        openAssignment == other.openAssignment &&
        stageSlots == other.stageSlots;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, shortId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, currentStage.hashCode);
    _$hash = $jc(_$hash, autonomy.hashCode);
    _$hash = $jc(_$hash, priority.hashCode);
    _$hash = $jc(_$hash, dueAt.hashCode);
    _$hash = $jc(_$hash, openAssignment.hashCode);
    _$hash = $jc(_$hash, stageSlots.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTaskChangedData_taskChanged')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('shortId', shortId)
          ..add('title', title)
          ..add('state', state)
          ..add('currentStage', currentStage)
          ..add('autonomy', autonomy)
          ..add('priority', priority)
          ..add('dueAt', dueAt)
          ..add('openAssignment', openAssignment)
          ..add('stageSlots', stageSlots))
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

  int? _shortId;
  int? get shortId => _$this._shortId;
  set shortId(int? shortId) => _$this._shortId = shortId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

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

  GTaskChangedData_taskChanged_openAssignmentBuilder? _openAssignment;
  GTaskChangedData_taskChanged_openAssignmentBuilder get openAssignment =>
      _$this._openAssignment ??=
          GTaskChangedData_taskChanged_openAssignmentBuilder();
  set openAssignment(
          GTaskChangedData_taskChanged_openAssignmentBuilder? openAssignment) =>
      _$this._openAssignment = openAssignment;

  ListBuilder<GTaskChangedData_taskChanged_stageSlots>? _stageSlots;
  ListBuilder<GTaskChangedData_taskChanged_stageSlots> get stageSlots =>
      _$this._stageSlots ??=
          ListBuilder<GTaskChangedData_taskChanged_stageSlots>();
  set stageSlots(
          ListBuilder<GTaskChangedData_taskChanged_stageSlots>? stageSlots) =>
      _$this._stageSlots = stageSlots;

  GTaskChangedData_taskChangedBuilder() {
    GTaskChangedData_taskChanged._initializeBuilder(this);
  }

  GTaskChangedData_taskChangedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _shortId = $v.shortId;
      _title = $v.title;
      _state = $v.state;
      _currentStage = $v.currentStage;
      _autonomy = $v.autonomy;
      _priority = $v.priority;
      _dueAt = $v.dueAt?.toBuilder();
      _openAssignment = $v.openAssignment?.toBuilder();
      _stageSlots = $v.stageSlots.toBuilder();
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
    _$GTaskChangedData_taskChanged _$result;
    try {
      _$result = _$v ??
          _$GTaskChangedData_taskChanged._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GTaskChangedData_taskChanged', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GTaskChangedData_taskChanged', 'id'),
            shortId: BuiltValueNullFieldError.checkNotNull(
                shortId, r'GTaskChangedData_taskChanged', 'shortId'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'GTaskChangedData_taskChanged', 'title'),
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'GTaskChangedData_taskChanged', 'state'),
            currentStage: BuiltValueNullFieldError.checkNotNull(
                currentStage, r'GTaskChangedData_taskChanged', 'currentStage'),
            autonomy: BuiltValueNullFieldError.checkNotNull(
                autonomy, r'GTaskChangedData_taskChanged', 'autonomy'),
            priority: BuiltValueNullFieldError.checkNotNull(
                priority, r'GTaskChangedData_taskChanged', 'priority'),
            dueAt: _dueAt?.build(),
            openAssignment: _openAssignment?.build(),
            stageSlots: stageSlots.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dueAt';
        _dueAt?.build();
        _$failedField = 'openAssignment';
        _openAssignment?.build();
        _$failedField = 'stageSlots';
        stageSlots.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GTaskChangedData_taskChanged', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTaskChangedData_taskChanged_openAssignment
    extends GTaskChangedData_taskChanged_openAssignment {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GTaskChangedData_taskChanged_openAssignment(
          [void Function(GTaskChangedData_taskChanged_openAssignmentBuilder)?
              updates]) =>
      (GTaskChangedData_taskChanged_openAssignmentBuilder()..update(updates))
          ._build();

  _$GTaskChangedData_taskChanged_openAssignment._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GTaskChangedData_taskChanged_openAssignment rebuild(
          void Function(GTaskChangedData_taskChanged_openAssignmentBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskChangedData_taskChanged_openAssignmentBuilder toBuilder() =>
      GTaskChangedData_taskChanged_openAssignmentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskChangedData_taskChanged_openAssignment &&
        G__typename == other.G__typename &&
        id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GTaskChangedData_taskChanged_openAssignment')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GTaskChangedData_taskChanged_openAssignmentBuilder
    implements
        Builder<GTaskChangedData_taskChanged_openAssignment,
            GTaskChangedData_taskChanged_openAssignmentBuilder> {
  _$GTaskChangedData_taskChanged_openAssignment? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GTaskChangedData_taskChanged_openAssignmentBuilder() {
    GTaskChangedData_taskChanged_openAssignment._initializeBuilder(this);
  }

  GTaskChangedData_taskChanged_openAssignmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskChangedData_taskChanged_openAssignment other) {
    _$v = other as _$GTaskChangedData_taskChanged_openAssignment;
  }

  @override
  void update(
      void Function(GTaskChangedData_taskChanged_openAssignmentBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskChangedData_taskChanged_openAssignment build() => _build();

  _$GTaskChangedData_taskChanged_openAssignment _build() {
    final _$result = _$v ??
        _$GTaskChangedData_taskChanged_openAssignment._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GTaskChangedData_taskChanged_openAssignment', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTaskChangedData_taskChanged_openAssignment', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GTaskChangedData_taskChanged_stageSlots
    extends GTaskChangedData_taskChanged_stageSlots {
  @override
  final String G__typename;
  @override
  final _i2.GAgentStage stage;
  @override
  final bool isHuman;
  @override
  final GTaskChangedData_taskChanged_stageSlots_occupant? occupant;

  factory _$GTaskChangedData_taskChanged_stageSlots(
          [void Function(GTaskChangedData_taskChanged_stageSlotsBuilder)?
              updates]) =>
      (GTaskChangedData_taskChanged_stageSlotsBuilder()..update(updates))
          ._build();

  _$GTaskChangedData_taskChanged_stageSlots._(
      {required this.G__typename,
      required this.stage,
      required this.isHuman,
      this.occupant})
      : super._();
  @override
  GTaskChangedData_taskChanged_stageSlots rebuild(
          void Function(GTaskChangedData_taskChanged_stageSlotsBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskChangedData_taskChanged_stageSlotsBuilder toBuilder() =>
      GTaskChangedData_taskChanged_stageSlotsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskChangedData_taskChanged_stageSlots &&
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
    return (newBuiltValueToStringHelper(
            r'GTaskChangedData_taskChanged_stageSlots')
          ..add('G__typename', G__typename)
          ..add('stage', stage)
          ..add('isHuman', isHuman)
          ..add('occupant', occupant))
        .toString();
  }
}

class GTaskChangedData_taskChanged_stageSlotsBuilder
    implements
        Builder<GTaskChangedData_taskChanged_stageSlots,
            GTaskChangedData_taskChanged_stageSlotsBuilder> {
  _$GTaskChangedData_taskChanged_stageSlots? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  _i2.GAgentStage? _stage;
  _i2.GAgentStage? get stage => _$this._stage;
  set stage(_i2.GAgentStage? stage) => _$this._stage = stage;

  bool? _isHuman;
  bool? get isHuman => _$this._isHuman;
  set isHuman(bool? isHuman) => _$this._isHuman = isHuman;

  GTaskChangedData_taskChanged_stageSlots_occupantBuilder? _occupant;
  GTaskChangedData_taskChanged_stageSlots_occupantBuilder get occupant =>
      _$this._occupant ??=
          GTaskChangedData_taskChanged_stageSlots_occupantBuilder();
  set occupant(
          GTaskChangedData_taskChanged_stageSlots_occupantBuilder? occupant) =>
      _$this._occupant = occupant;

  GTaskChangedData_taskChanged_stageSlotsBuilder() {
    GTaskChangedData_taskChanged_stageSlots._initializeBuilder(this);
  }

  GTaskChangedData_taskChanged_stageSlotsBuilder get _$this {
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
  void replace(GTaskChangedData_taskChanged_stageSlots other) {
    _$v = other as _$GTaskChangedData_taskChanged_stageSlots;
  }

  @override
  void update(
      void Function(GTaskChangedData_taskChanged_stageSlotsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskChangedData_taskChanged_stageSlots build() => _build();

  _$GTaskChangedData_taskChanged_stageSlots _build() {
    _$GTaskChangedData_taskChanged_stageSlots _$result;
    try {
      _$result = _$v ??
          _$GTaskChangedData_taskChanged_stageSlots._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GTaskChangedData_taskChanged_stageSlots', 'G__typename'),
            stage: BuiltValueNullFieldError.checkNotNull(
                stage, r'GTaskChangedData_taskChanged_stageSlots', 'stage'),
            isHuman: BuiltValueNullFieldError.checkNotNull(
                isHuman, r'GTaskChangedData_taskChanged_stageSlots', 'isHuman'),
            occupant: _occupant?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'occupant';
        _occupant?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GTaskChangedData_taskChanged_stageSlots',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTaskChangedData_taskChanged_stageSlots_occupant
    extends GTaskChangedData_taskChanged_stageSlots_occupant {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String name;
  @override
  final String? model;

  factory _$GTaskChangedData_taskChanged_stageSlots_occupant(
          [void Function(
                  GTaskChangedData_taskChanged_stageSlots_occupantBuilder)?
              updates]) =>
      (GTaskChangedData_taskChanged_stageSlots_occupantBuilder()
            ..update(updates))
          ._build();

  _$GTaskChangedData_taskChanged_stageSlots_occupant._(
      {required this.G__typename,
      required this.id,
      required this.name,
      this.model})
      : super._();
  @override
  GTaskChangedData_taskChanged_stageSlots_occupant rebuild(
          void Function(GTaskChangedData_taskChanged_stageSlots_occupantBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskChangedData_taskChanged_stageSlots_occupantBuilder toBuilder() =>
      GTaskChangedData_taskChanged_stageSlots_occupantBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskChangedData_taskChanged_stageSlots_occupant &&
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
            r'GTaskChangedData_taskChanged_stageSlots_occupant')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('name', name)
          ..add('model', model))
        .toString();
  }
}

class GTaskChangedData_taskChanged_stageSlots_occupantBuilder
    implements
        Builder<GTaskChangedData_taskChanged_stageSlots_occupant,
            GTaskChangedData_taskChanged_stageSlots_occupantBuilder> {
  _$GTaskChangedData_taskChanged_stageSlots_occupant? _$v;

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

  GTaskChangedData_taskChanged_stageSlots_occupantBuilder() {
    GTaskChangedData_taskChanged_stageSlots_occupant._initializeBuilder(this);
  }

  GTaskChangedData_taskChanged_stageSlots_occupantBuilder get _$this {
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
  void replace(GTaskChangedData_taskChanged_stageSlots_occupant other) {
    _$v = other as _$GTaskChangedData_taskChanged_stageSlots_occupant;
  }

  @override
  void update(
      void Function(GTaskChangedData_taskChanged_stageSlots_occupantBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskChangedData_taskChanged_stageSlots_occupant build() => _build();

  _$GTaskChangedData_taskChanged_stageSlots_occupant _build() {
    final _$result = _$v ??
        _$GTaskChangedData_taskChanged_stageSlots_occupant._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GTaskChangedData_taskChanged_stageSlots_occupant',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTaskChangedData_taskChanged_stageSlots_occupant', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(name,
              r'GTaskChangedData_taskChanged_stageSlots_occupant', 'name'),
          model: model,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
