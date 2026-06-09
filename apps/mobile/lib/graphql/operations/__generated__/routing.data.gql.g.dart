// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routing.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GTaskStageSlotsData> _$gTaskStageSlotsDataSerializer =
    _$GTaskStageSlotsDataSerializer();
Serializer<GTaskStageSlotsData_task> _$gTaskStageSlotsDataTaskSerializer =
    _$GTaskStageSlotsData_taskSerializer();
Serializer<GTaskStageSlotsData_task_stageSlots>
    _$gTaskStageSlotsDataTaskStageSlotsSerializer =
    _$GTaskStageSlotsData_task_stageSlotsSerializer();
Serializer<GTaskStageSlotsData_task_stageSlots_occupant>
    _$gTaskStageSlotsDataTaskStageSlotsOccupantSerializer =
    _$GTaskStageSlotsData_task_stageSlots_occupantSerializer();
Serializer<GAgentConfigsData> _$gAgentConfigsDataSerializer =
    _$GAgentConfigsDataSerializer();
Serializer<GAgentConfigsData_agentConfigs>
    _$gAgentConfigsDataAgentConfigsSerializer =
    _$GAgentConfigsData_agentConfigsSerializer();

class _$GTaskStageSlotsDataSerializer
    implements StructuredSerializer<GTaskStageSlotsData> {
  @override
  final Iterable<Type> types = const [
    GTaskStageSlotsData,
    _$GTaskStageSlotsData
  ];
  @override
  final String wireName = 'GTaskStageSlotsData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskStageSlotsData object,
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
            specifiedType: const FullType(GTaskStageSlotsData_task)));
    }
    return result;
  }

  @override
  GTaskStageSlotsData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskStageSlotsDataBuilder();

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
                  specifiedType: const FullType(GTaskStageSlotsData_task))!
              as GTaskStageSlotsData_task);
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskStageSlotsData_taskSerializer
    implements StructuredSerializer<GTaskStageSlotsData_task> {
  @override
  final Iterable<Type> types = const [
    GTaskStageSlotsData_task,
    _$GTaskStageSlotsData_task
  ];
  @override
  final String wireName = 'GTaskStageSlotsData_task';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskStageSlotsData_task object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'stageSlots',
      serializers.serialize(object.stageSlots,
          specifiedType: const FullType(BuiltList,
              const [const FullType(GTaskStageSlotsData_task_stageSlots)])),
    ];

    return result;
  }

  @override
  GTaskStageSlotsData_task deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskStageSlotsData_taskBuilder();

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
        case 'stageSlots':
          result.stageSlots.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GTaskStageSlotsData_task_stageSlots)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskStageSlotsData_task_stageSlotsSerializer
    implements StructuredSerializer<GTaskStageSlotsData_task_stageSlots> {
  @override
  final Iterable<Type> types = const [
    GTaskStageSlotsData_task_stageSlots,
    _$GTaskStageSlotsData_task_stageSlots
  ];
  @override
  final String wireName = 'GTaskStageSlotsData_task_stageSlots';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskStageSlotsData_task_stageSlots object,
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
                const FullType(GTaskStageSlotsData_task_stageSlots_occupant)));
    }
    return result;
  }

  @override
  GTaskStageSlotsData_task_stageSlots deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskStageSlotsData_task_stageSlotsBuilder();

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
                      GTaskStageSlotsData_task_stageSlots_occupant))!
              as GTaskStageSlotsData_task_stageSlots_occupant);
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskStageSlotsData_task_stageSlots_occupantSerializer
    implements
        StructuredSerializer<GTaskStageSlotsData_task_stageSlots_occupant> {
  @override
  final Iterable<Type> types = const [
    GTaskStageSlotsData_task_stageSlots_occupant,
    _$GTaskStageSlotsData_task_stageSlots_occupant
  ];
  @override
  final String wireName = 'GTaskStageSlotsData_task_stageSlots_occupant';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GTaskStageSlotsData_task_stageSlots_occupant object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'stage',
      serializers.serialize(object.stage,
          specifiedType: const FullType(_i2.GAgentStage)),
      'isHuman',
      serializers.serialize(object.isHuman,
          specifiedType: const FullType(bool)),
      'origin',
      serializers.serialize(object.origin,
          specifiedType: const FullType(String)),
      'version',
      serializers.serialize(object.version, specifiedType: const FullType(int)),
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
  GTaskStageSlotsData_task_stageSlots_occupant deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskStageSlotsData_task_stageSlots_occupantBuilder();

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
        case 'stage':
          result.stage = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GAgentStage))!
              as _i2.GAgentStage;
          break;
        case 'isHuman':
          result.isHuman = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'model':
          result.model = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'origin':
          result.origin = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'version':
          result.version = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
      }
    }

    return result.build();
  }
}

class _$GAgentConfigsDataSerializer
    implements StructuredSerializer<GAgentConfigsData> {
  @override
  final Iterable<Type> types = const [GAgentConfigsData, _$GAgentConfigsData];
  @override
  final String wireName = 'GAgentConfigsData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GAgentConfigsData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'agentConfigs',
      serializers.serialize(object.agentConfigs,
          specifiedType: const FullType(BuiltList,
              const [const FullType(GAgentConfigsData_agentConfigs)])),
    ];

    return result;
  }

  @override
  GAgentConfigsData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAgentConfigsDataBuilder();

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
        case 'agentConfigs':
          result.agentConfigs.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GAgentConfigsData_agentConfigs)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GAgentConfigsData_agentConfigsSerializer
    implements StructuredSerializer<GAgentConfigsData_agentConfigs> {
  @override
  final Iterable<Type> types = const [
    GAgentConfigsData_agentConfigs,
    _$GAgentConfigsData_agentConfigs
  ];
  @override
  final String wireName = 'GAgentConfigsData_agentConfigs';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAgentConfigsData_agentConfigs object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'stage',
      serializers.serialize(object.stage,
          specifiedType: const FullType(_i2.GAgentStage)),
      'isHuman',
      serializers.serialize(object.isHuman,
          specifiedType: const FullType(bool)),
      'origin',
      serializers.serialize(object.origin,
          specifiedType: const FullType(String)),
      'version',
      serializers.serialize(object.version, specifiedType: const FullType(int)),
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
  GAgentConfigsData_agentConfigs deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAgentConfigsData_agentConfigsBuilder();

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
        case 'stage':
          result.stage = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GAgentStage))!
              as _i2.GAgentStage;
          break;
        case 'isHuman':
          result.isHuman = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'model':
          result.model = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'origin':
          result.origin = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'version':
          result.version = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskStageSlotsData extends GTaskStageSlotsData {
  @override
  final String G__typename;
  @override
  final GTaskStageSlotsData_task? task;

  factory _$GTaskStageSlotsData(
          [void Function(GTaskStageSlotsDataBuilder)? updates]) =>
      (GTaskStageSlotsDataBuilder()..update(updates))._build();

  _$GTaskStageSlotsData._({required this.G__typename, this.task}) : super._();
  @override
  GTaskStageSlotsData rebuild(
          void Function(GTaskStageSlotsDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskStageSlotsDataBuilder toBuilder() =>
      GTaskStageSlotsDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskStageSlotsData &&
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
    return (newBuiltValueToStringHelper(r'GTaskStageSlotsData')
          ..add('G__typename', G__typename)
          ..add('task', task))
        .toString();
  }
}

class GTaskStageSlotsDataBuilder
    implements Builder<GTaskStageSlotsData, GTaskStageSlotsDataBuilder> {
  _$GTaskStageSlotsData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GTaskStageSlotsData_taskBuilder? _task;
  GTaskStageSlotsData_taskBuilder get task =>
      _$this._task ??= GTaskStageSlotsData_taskBuilder();
  set task(GTaskStageSlotsData_taskBuilder? task) => _$this._task = task;

  GTaskStageSlotsDataBuilder() {
    GTaskStageSlotsData._initializeBuilder(this);
  }

  GTaskStageSlotsDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _task = $v.task?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskStageSlotsData other) {
    _$v = other as _$GTaskStageSlotsData;
  }

  @override
  void update(void Function(GTaskStageSlotsDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskStageSlotsData build() => _build();

  _$GTaskStageSlotsData _build() {
    _$GTaskStageSlotsData _$result;
    try {
      _$result = _$v ??
          _$GTaskStageSlotsData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GTaskStageSlotsData', 'G__typename'),
            task: _task?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'task';
        _task?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GTaskStageSlotsData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTaskStageSlotsData_task extends GTaskStageSlotsData_task {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final BuiltList<GTaskStageSlotsData_task_stageSlots> stageSlots;

  factory _$GTaskStageSlotsData_task(
          [void Function(GTaskStageSlotsData_taskBuilder)? updates]) =>
      (GTaskStageSlotsData_taskBuilder()..update(updates))._build();

  _$GTaskStageSlotsData_task._(
      {required this.G__typename, required this.id, required this.stageSlots})
      : super._();
  @override
  GTaskStageSlotsData_task rebuild(
          void Function(GTaskStageSlotsData_taskBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskStageSlotsData_taskBuilder toBuilder() =>
      GTaskStageSlotsData_taskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskStageSlotsData_task &&
        G__typename == other.G__typename &&
        id == other.id &&
        stageSlots == other.stageSlots;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, stageSlots.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTaskStageSlotsData_task')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('stageSlots', stageSlots))
        .toString();
  }
}

class GTaskStageSlotsData_taskBuilder
    implements
        Builder<GTaskStageSlotsData_task, GTaskStageSlotsData_taskBuilder> {
  _$GTaskStageSlotsData_task? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ListBuilder<GTaskStageSlotsData_task_stageSlots>? _stageSlots;
  ListBuilder<GTaskStageSlotsData_task_stageSlots> get stageSlots =>
      _$this._stageSlots ??= ListBuilder<GTaskStageSlotsData_task_stageSlots>();
  set stageSlots(
          ListBuilder<GTaskStageSlotsData_task_stageSlots>? stageSlots) =>
      _$this._stageSlots = stageSlots;

  GTaskStageSlotsData_taskBuilder() {
    GTaskStageSlotsData_task._initializeBuilder(this);
  }

  GTaskStageSlotsData_taskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _stageSlots = $v.stageSlots.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskStageSlotsData_task other) {
    _$v = other as _$GTaskStageSlotsData_task;
  }

  @override
  void update(void Function(GTaskStageSlotsData_taskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskStageSlotsData_task build() => _build();

  _$GTaskStageSlotsData_task _build() {
    _$GTaskStageSlotsData_task _$result;
    try {
      _$result = _$v ??
          _$GTaskStageSlotsData_task._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GTaskStageSlotsData_task', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GTaskStageSlotsData_task', 'id'),
            stageSlots: stageSlots.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'stageSlots';
        stageSlots.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GTaskStageSlotsData_task', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTaskStageSlotsData_task_stageSlots
    extends GTaskStageSlotsData_task_stageSlots {
  @override
  final String G__typename;
  @override
  final _i2.GAgentStage stage;
  @override
  final bool isHuman;
  @override
  final GTaskStageSlotsData_task_stageSlots_occupant? occupant;

  factory _$GTaskStageSlotsData_task_stageSlots(
          [void Function(GTaskStageSlotsData_task_stageSlotsBuilder)?
              updates]) =>
      (GTaskStageSlotsData_task_stageSlotsBuilder()..update(updates))._build();

  _$GTaskStageSlotsData_task_stageSlots._(
      {required this.G__typename,
      required this.stage,
      required this.isHuman,
      this.occupant})
      : super._();
  @override
  GTaskStageSlotsData_task_stageSlots rebuild(
          void Function(GTaskStageSlotsData_task_stageSlotsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskStageSlotsData_task_stageSlotsBuilder toBuilder() =>
      GTaskStageSlotsData_task_stageSlotsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskStageSlotsData_task_stageSlots &&
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
    return (newBuiltValueToStringHelper(r'GTaskStageSlotsData_task_stageSlots')
          ..add('G__typename', G__typename)
          ..add('stage', stage)
          ..add('isHuman', isHuman)
          ..add('occupant', occupant))
        .toString();
  }
}

class GTaskStageSlotsData_task_stageSlotsBuilder
    implements
        Builder<GTaskStageSlotsData_task_stageSlots,
            GTaskStageSlotsData_task_stageSlotsBuilder> {
  _$GTaskStageSlotsData_task_stageSlots? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  _i2.GAgentStage? _stage;
  _i2.GAgentStage? get stage => _$this._stage;
  set stage(_i2.GAgentStage? stage) => _$this._stage = stage;

  bool? _isHuman;
  bool? get isHuman => _$this._isHuman;
  set isHuman(bool? isHuman) => _$this._isHuman = isHuman;

  GTaskStageSlotsData_task_stageSlots_occupantBuilder? _occupant;
  GTaskStageSlotsData_task_stageSlots_occupantBuilder get occupant =>
      _$this._occupant ??=
          GTaskStageSlotsData_task_stageSlots_occupantBuilder();
  set occupant(GTaskStageSlotsData_task_stageSlots_occupantBuilder? occupant) =>
      _$this._occupant = occupant;

  GTaskStageSlotsData_task_stageSlotsBuilder() {
    GTaskStageSlotsData_task_stageSlots._initializeBuilder(this);
  }

  GTaskStageSlotsData_task_stageSlotsBuilder get _$this {
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
  void replace(GTaskStageSlotsData_task_stageSlots other) {
    _$v = other as _$GTaskStageSlotsData_task_stageSlots;
  }

  @override
  void update(
      void Function(GTaskStageSlotsData_task_stageSlotsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskStageSlotsData_task_stageSlots build() => _build();

  _$GTaskStageSlotsData_task_stageSlots _build() {
    _$GTaskStageSlotsData_task_stageSlots _$result;
    try {
      _$result = _$v ??
          _$GTaskStageSlotsData_task_stageSlots._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GTaskStageSlotsData_task_stageSlots', 'G__typename'),
            stage: BuiltValueNullFieldError.checkNotNull(
                stage, r'GTaskStageSlotsData_task_stageSlots', 'stage'),
            isHuman: BuiltValueNullFieldError.checkNotNull(
                isHuman, r'GTaskStageSlotsData_task_stageSlots', 'isHuman'),
            occupant: _occupant?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'occupant';
        _occupant?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'GTaskStageSlotsData_task_stageSlots',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTaskStageSlotsData_task_stageSlots_occupant
    extends GTaskStageSlotsData_task_stageSlots_occupant {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String name;
  @override
  final _i2.GAgentStage stage;
  @override
  final bool isHuman;
  @override
  final String? model;
  @override
  final String origin;
  @override
  final int version;

  factory _$GTaskStageSlotsData_task_stageSlots_occupant(
          [void Function(GTaskStageSlotsData_task_stageSlots_occupantBuilder)?
              updates]) =>
      (GTaskStageSlotsData_task_stageSlots_occupantBuilder()..update(updates))
          ._build();

  _$GTaskStageSlotsData_task_stageSlots_occupant._(
      {required this.G__typename,
      required this.id,
      required this.name,
      required this.stage,
      required this.isHuman,
      this.model,
      required this.origin,
      required this.version})
      : super._();
  @override
  GTaskStageSlotsData_task_stageSlots_occupant rebuild(
          void Function(GTaskStageSlotsData_task_stageSlots_occupantBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskStageSlotsData_task_stageSlots_occupantBuilder toBuilder() =>
      GTaskStageSlotsData_task_stageSlots_occupantBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskStageSlotsData_task_stageSlots_occupant &&
        G__typename == other.G__typename &&
        id == other.id &&
        name == other.name &&
        stage == other.stage &&
        isHuman == other.isHuman &&
        model == other.model &&
        origin == other.origin &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jc(_$hash, isHuman.hashCode);
    _$hash = $jc(_$hash, model.hashCode);
    _$hash = $jc(_$hash, origin.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GTaskStageSlotsData_task_stageSlots_occupant')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('name', name)
          ..add('stage', stage)
          ..add('isHuman', isHuman)
          ..add('model', model)
          ..add('origin', origin)
          ..add('version', version))
        .toString();
  }
}

class GTaskStageSlotsData_task_stageSlots_occupantBuilder
    implements
        Builder<GTaskStageSlotsData_task_stageSlots_occupant,
            GTaskStageSlotsData_task_stageSlots_occupantBuilder> {
  _$GTaskStageSlotsData_task_stageSlots_occupant? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  _i2.GAgentStage? _stage;
  _i2.GAgentStage? get stage => _$this._stage;
  set stage(_i2.GAgentStage? stage) => _$this._stage = stage;

  bool? _isHuman;
  bool? get isHuman => _$this._isHuman;
  set isHuman(bool? isHuman) => _$this._isHuman = isHuman;

  String? _model;
  String? get model => _$this._model;
  set model(String? model) => _$this._model = model;

  String? _origin;
  String? get origin => _$this._origin;
  set origin(String? origin) => _$this._origin = origin;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  GTaskStageSlotsData_task_stageSlots_occupantBuilder() {
    GTaskStageSlotsData_task_stageSlots_occupant._initializeBuilder(this);
  }

  GTaskStageSlotsData_task_stageSlots_occupantBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _name = $v.name;
      _stage = $v.stage;
      _isHuman = $v.isHuman;
      _model = $v.model;
      _origin = $v.origin;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskStageSlotsData_task_stageSlots_occupant other) {
    _$v = other as _$GTaskStageSlotsData_task_stageSlots_occupant;
  }

  @override
  void update(
      void Function(GTaskStageSlotsData_task_stageSlots_occupantBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskStageSlotsData_task_stageSlots_occupant build() => _build();

  _$GTaskStageSlotsData_task_stageSlots_occupant _build() {
    final _$result = _$v ??
        _$GTaskStageSlotsData_task_stageSlots_occupant._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GTaskStageSlotsData_task_stageSlots_occupant', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTaskStageSlotsData_task_stageSlots_occupant', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GTaskStageSlotsData_task_stageSlots_occupant', 'name'),
          stage: BuiltValueNullFieldError.checkNotNull(
              stage, r'GTaskStageSlotsData_task_stageSlots_occupant', 'stage'),
          isHuman: BuiltValueNullFieldError.checkNotNull(isHuman,
              r'GTaskStageSlotsData_task_stageSlots_occupant', 'isHuman'),
          model: model,
          origin: BuiltValueNullFieldError.checkNotNull(origin,
              r'GTaskStageSlotsData_task_stageSlots_occupant', 'origin'),
          version: BuiltValueNullFieldError.checkNotNull(version,
              r'GTaskStageSlotsData_task_stageSlots_occupant', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GAgentConfigsData extends GAgentConfigsData {
  @override
  final String G__typename;
  @override
  final BuiltList<GAgentConfigsData_agentConfigs> agentConfigs;

  factory _$GAgentConfigsData(
          [void Function(GAgentConfigsDataBuilder)? updates]) =>
      (GAgentConfigsDataBuilder()..update(updates))._build();

  _$GAgentConfigsData._({required this.G__typename, required this.agentConfigs})
      : super._();
  @override
  GAgentConfigsData rebuild(void Function(GAgentConfigsDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAgentConfigsDataBuilder toBuilder() =>
      GAgentConfigsDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAgentConfigsData &&
        G__typename == other.G__typename &&
        agentConfigs == other.agentConfigs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, agentConfigs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAgentConfigsData')
          ..add('G__typename', G__typename)
          ..add('agentConfigs', agentConfigs))
        .toString();
  }
}

class GAgentConfigsDataBuilder
    implements Builder<GAgentConfigsData, GAgentConfigsDataBuilder> {
  _$GAgentConfigsData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  ListBuilder<GAgentConfigsData_agentConfigs>? _agentConfigs;
  ListBuilder<GAgentConfigsData_agentConfigs> get agentConfigs =>
      _$this._agentConfigs ??= ListBuilder<GAgentConfigsData_agentConfigs>();
  set agentConfigs(ListBuilder<GAgentConfigsData_agentConfigs>? agentConfigs) =>
      _$this._agentConfigs = agentConfigs;

  GAgentConfigsDataBuilder() {
    GAgentConfigsData._initializeBuilder(this);
  }

  GAgentConfigsDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _agentConfigs = $v.agentConfigs.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAgentConfigsData other) {
    _$v = other as _$GAgentConfigsData;
  }

  @override
  void update(void Function(GAgentConfigsDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAgentConfigsData build() => _build();

  _$GAgentConfigsData _build() {
    _$GAgentConfigsData _$result;
    try {
      _$result = _$v ??
          _$GAgentConfigsData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GAgentConfigsData', 'G__typename'),
            agentConfigs: agentConfigs.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'agentConfigs';
        agentConfigs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GAgentConfigsData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GAgentConfigsData_agentConfigs extends GAgentConfigsData_agentConfigs {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String name;
  @override
  final _i2.GAgentStage stage;
  @override
  final bool isHuman;
  @override
  final String? model;
  @override
  final String origin;
  @override
  final int version;

  factory _$GAgentConfigsData_agentConfigs(
          [void Function(GAgentConfigsData_agentConfigsBuilder)? updates]) =>
      (GAgentConfigsData_agentConfigsBuilder()..update(updates))._build();

  _$GAgentConfigsData_agentConfigs._(
      {required this.G__typename,
      required this.id,
      required this.name,
      required this.stage,
      required this.isHuman,
      this.model,
      required this.origin,
      required this.version})
      : super._();
  @override
  GAgentConfigsData_agentConfigs rebuild(
          void Function(GAgentConfigsData_agentConfigsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAgentConfigsData_agentConfigsBuilder toBuilder() =>
      GAgentConfigsData_agentConfigsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAgentConfigsData_agentConfigs &&
        G__typename == other.G__typename &&
        id == other.id &&
        name == other.name &&
        stage == other.stage &&
        isHuman == other.isHuman &&
        model == other.model &&
        origin == other.origin &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jc(_$hash, isHuman.hashCode);
    _$hash = $jc(_$hash, model.hashCode);
    _$hash = $jc(_$hash, origin.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAgentConfigsData_agentConfigs')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('name', name)
          ..add('stage', stage)
          ..add('isHuman', isHuman)
          ..add('model', model)
          ..add('origin', origin)
          ..add('version', version))
        .toString();
  }
}

class GAgentConfigsData_agentConfigsBuilder
    implements
        Builder<GAgentConfigsData_agentConfigs,
            GAgentConfigsData_agentConfigsBuilder> {
  _$GAgentConfigsData_agentConfigs? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  _i2.GAgentStage? _stage;
  _i2.GAgentStage? get stage => _$this._stage;
  set stage(_i2.GAgentStage? stage) => _$this._stage = stage;

  bool? _isHuman;
  bool? get isHuman => _$this._isHuman;
  set isHuman(bool? isHuman) => _$this._isHuman = isHuman;

  String? _model;
  String? get model => _$this._model;
  set model(String? model) => _$this._model = model;

  String? _origin;
  String? get origin => _$this._origin;
  set origin(String? origin) => _$this._origin = origin;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  GAgentConfigsData_agentConfigsBuilder() {
    GAgentConfigsData_agentConfigs._initializeBuilder(this);
  }

  GAgentConfigsData_agentConfigsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _name = $v.name;
      _stage = $v.stage;
      _isHuman = $v.isHuman;
      _model = $v.model;
      _origin = $v.origin;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAgentConfigsData_agentConfigs other) {
    _$v = other as _$GAgentConfigsData_agentConfigs;
  }

  @override
  void update(void Function(GAgentConfigsData_agentConfigsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAgentConfigsData_agentConfigs build() => _build();

  _$GAgentConfigsData_agentConfigs _build() {
    final _$result = _$v ??
        _$GAgentConfigsData_agentConfigs._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GAgentConfigsData_agentConfigs', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GAgentConfigsData_agentConfigs', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GAgentConfigsData_agentConfigs', 'name'),
          stage: BuiltValueNullFieldError.checkNotNull(
              stage, r'GAgentConfigsData_agentConfigs', 'stage'),
          isHuman: BuiltValueNullFieldError.checkNotNull(
              isHuman, r'GAgentConfigsData_agentConfigs', 'isHuman'),
          model: model,
          origin: BuiltValueNullFieldError.checkNotNull(
              origin, r'GAgentConfigsData_agentConfigs', 'origin'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'GAgentConfigsData_agentConfigs', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
