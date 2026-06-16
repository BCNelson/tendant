// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GTasksData> _$gTasksDataSerializer = _$GTasksDataSerializer();
Serializer<GTasksData_tasks> _$gTasksDataTasksSerializer =
    _$GTasksData_tasksSerializer();
Serializer<GTasksData_tasks_edges> _$gTasksDataTasksEdgesSerializer =
    _$GTasksData_tasks_edgesSerializer();
Serializer<GTasksData_tasks_edges_node> _$gTasksDataTasksEdgesNodeSerializer =
    _$GTasksData_tasks_edges_nodeSerializer();
Serializer<GTasksData_tasks_edges_node_openAssignment>
    _$gTasksDataTasksEdgesNodeOpenAssignmentSerializer =
    _$GTasksData_tasks_edges_node_openAssignmentSerializer();
Serializer<GTasksData_tasks_edges_node_stageSlots>
    _$gTasksDataTasksEdgesNodeStageSlotsSerializer =
    _$GTasksData_tasks_edges_node_stageSlotsSerializer();
Serializer<GTasksData_tasks_edges_node_stageSlots_occupant>
    _$gTasksDataTasksEdgesNodeStageSlotsOccupantSerializer =
    _$GTasksData_tasks_edges_node_stageSlots_occupantSerializer();
Serializer<GTasksData_tasks_pageInfo> _$gTasksDataTasksPageInfoSerializer =
    _$GTasksData_tasks_pageInfoSerializer();

class _$GTasksDataSerializer implements StructuredSerializer<GTasksData> {
  @override
  final Iterable<Type> types = const [GTasksData, _$GTasksData];
  @override
  final String wireName = 'GTasksData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GTasksData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'tasks',
      serializers.serialize(object.tasks,
          specifiedType: const FullType(GTasksData_tasks)),
    ];

    return result;
  }

  @override
  GTasksData deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTasksDataBuilder();

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
        case 'tasks':
          result.tasks.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GTasksData_tasks))!
              as GTasksData_tasks);
          break;
      }
    }

    return result.build();
  }
}

class _$GTasksData_tasksSerializer
    implements StructuredSerializer<GTasksData_tasks> {
  @override
  final Iterable<Type> types = const [GTasksData_tasks, _$GTasksData_tasks];
  @override
  final String wireName = 'GTasksData_tasks';

  @override
  Iterable<Object?> serialize(Serializers serializers, GTasksData_tasks object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'edges',
      serializers.serialize(object.edges,
          specifiedType: const FullType(
              BuiltList, const [const FullType(GTasksData_tasks_edges)])),
      'pageInfo',
      serializers.serialize(object.pageInfo,
          specifiedType: const FullType(GTasksData_tasks_pageInfo)),
    ];

    return result;
  }

  @override
  GTasksData_tasks deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTasksData_tasksBuilder();

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
        case 'edges':
          result.edges.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GTasksData_tasks_edges)
              ]))! as BuiltList<Object?>);
          break;
        case 'pageInfo':
          result.pageInfo.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GTasksData_tasks_pageInfo))!
              as GTasksData_tasks_pageInfo);
          break;
      }
    }

    return result.build();
  }
}

class _$GTasksData_tasks_edgesSerializer
    implements StructuredSerializer<GTasksData_tasks_edges> {
  @override
  final Iterable<Type> types = const [
    GTasksData_tasks_edges,
    _$GTasksData_tasks_edges
  ];
  @override
  final String wireName = 'GTasksData_tasks_edges';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTasksData_tasks_edges object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'node',
      serializers.serialize(object.node,
          specifiedType: const FullType(GTasksData_tasks_edges_node)),
    ];

    return result;
  }

  @override
  GTasksData_tasks_edges deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTasksData_tasks_edgesBuilder();

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
        case 'node':
          result.node.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GTasksData_tasks_edges_node))!
              as GTasksData_tasks_edges_node);
          break;
      }
    }

    return result.build();
  }
}

class _$GTasksData_tasks_edges_nodeSerializer
    implements StructuredSerializer<GTasksData_tasks_edges_node> {
  @override
  final Iterable<Type> types = const [
    GTasksData_tasks_edges_node,
    _$GTasksData_tasks_edges_node
  ];
  @override
  final String wireName = 'GTasksData_tasks_edges_node';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTasksData_tasks_edges_node object,
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
      'stageSlots',
      serializers.serialize(object.stageSlots,
          specifiedType: const FullType(BuiltList,
              const [const FullType(GTasksData_tasks_edges_node_stageSlots)])),
    ];
    Object? value;
    value = object.openAssignment;
    if (value != null) {
      result
        ..add('openAssignment')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(GTasksData_tasks_edges_node_openAssignment)));
    }
    return result;
  }

  @override
  GTasksData_tasks_edges_node deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTasksData_tasks_edges_nodeBuilder();

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
        case 'openAssignment':
          result.openAssignment.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GTasksData_tasks_edges_node_openAssignment))!
              as GTasksData_tasks_edges_node_openAssignment);
          break;
        case 'stageSlots':
          result.stageSlots.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GTasksData_tasks_edges_node_stageSlots)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GTasksData_tasks_edges_node_openAssignmentSerializer
    implements
        StructuredSerializer<GTasksData_tasks_edges_node_openAssignment> {
  @override
  final Iterable<Type> types = const [
    GTasksData_tasks_edges_node_openAssignment,
    _$GTasksData_tasks_edges_node_openAssignment
  ];
  @override
  final String wireName = 'GTasksData_tasks_edges_node_openAssignment';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GTasksData_tasks_edges_node_openAssignment object,
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
  GTasksData_tasks_edges_node_openAssignment deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTasksData_tasks_edges_node_openAssignmentBuilder();

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

class _$GTasksData_tasks_edges_node_stageSlotsSerializer
    implements StructuredSerializer<GTasksData_tasks_edges_node_stageSlots> {
  @override
  final Iterable<Type> types = const [
    GTasksData_tasks_edges_node_stageSlots,
    _$GTasksData_tasks_edges_node_stageSlots
  ];
  @override
  final String wireName = 'GTasksData_tasks_edges_node_stageSlots';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTasksData_tasks_edges_node_stageSlots object,
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
                GTasksData_tasks_edges_node_stageSlots_occupant)));
    }
    return result;
  }

  @override
  GTasksData_tasks_edges_node_stageSlots deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTasksData_tasks_edges_node_stageSlotsBuilder();

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
                      GTasksData_tasks_edges_node_stageSlots_occupant))!
              as GTasksData_tasks_edges_node_stageSlots_occupant);
          break;
      }
    }

    return result.build();
  }
}

class _$GTasksData_tasks_edges_node_stageSlots_occupantSerializer
    implements
        StructuredSerializer<GTasksData_tasks_edges_node_stageSlots_occupant> {
  @override
  final Iterable<Type> types = const [
    GTasksData_tasks_edges_node_stageSlots_occupant,
    _$GTasksData_tasks_edges_node_stageSlots_occupant
  ];
  @override
  final String wireName = 'GTasksData_tasks_edges_node_stageSlots_occupant';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GTasksData_tasks_edges_node_stageSlots_occupant object,
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
  GTasksData_tasks_edges_node_stageSlots_occupant deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTasksData_tasks_edges_node_stageSlots_occupantBuilder();

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

class _$GTasksData_tasks_pageInfoSerializer
    implements StructuredSerializer<GTasksData_tasks_pageInfo> {
  @override
  final Iterable<Type> types = const [
    GTasksData_tasks_pageInfo,
    _$GTasksData_tasks_pageInfo
  ];
  @override
  final String wireName = 'GTasksData_tasks_pageInfo';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTasksData_tasks_pageInfo object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'hasNextPage',
      serializers.serialize(object.hasNextPage,
          specifiedType: const FullType(bool)),
    ];
    Object? value;
    value = object.endCursor;
    if (value != null) {
      result
        ..add('endCursor')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GTasksData_tasks_pageInfo deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTasksData_tasks_pageInfoBuilder();

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
        case 'hasNextPage':
          result.hasNextPage = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'endCursor':
          result.endCursor = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GTasksData extends GTasksData {
  @override
  final String G__typename;
  @override
  final GTasksData_tasks tasks;

  factory _$GTasksData([void Function(GTasksDataBuilder)? updates]) =>
      (GTasksDataBuilder()..update(updates))._build();

  _$GTasksData._({required this.G__typename, required this.tasks}) : super._();
  @override
  GTasksData rebuild(void Function(GTasksDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTasksDataBuilder toBuilder() => GTasksDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTasksData &&
        G__typename == other.G__typename &&
        tasks == other.tasks;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, tasks.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTasksData')
          ..add('G__typename', G__typename)
          ..add('tasks', tasks))
        .toString();
  }
}

class GTasksDataBuilder implements Builder<GTasksData, GTasksDataBuilder> {
  _$GTasksData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GTasksData_tasksBuilder? _tasks;
  GTasksData_tasksBuilder get tasks =>
      _$this._tasks ??= GTasksData_tasksBuilder();
  set tasks(GTasksData_tasksBuilder? tasks) => _$this._tasks = tasks;

  GTasksDataBuilder() {
    GTasksData._initializeBuilder(this);
  }

  GTasksDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _tasks = $v.tasks.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTasksData other) {
    _$v = other as _$GTasksData;
  }

  @override
  void update(void Function(GTasksDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTasksData build() => _build();

  _$GTasksData _build() {
    _$GTasksData _$result;
    try {
      _$result = _$v ??
          _$GTasksData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GTasksData', 'G__typename'),
            tasks: tasks.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tasks';
        tasks.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GTasksData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTasksData_tasks extends GTasksData_tasks {
  @override
  final String G__typename;
  @override
  final BuiltList<GTasksData_tasks_edges> edges;
  @override
  final GTasksData_tasks_pageInfo pageInfo;

  factory _$GTasksData_tasks(
          [void Function(GTasksData_tasksBuilder)? updates]) =>
      (GTasksData_tasksBuilder()..update(updates))._build();

  _$GTasksData_tasks._(
      {required this.G__typename, required this.edges, required this.pageInfo})
      : super._();
  @override
  GTasksData_tasks rebuild(void Function(GTasksData_tasksBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTasksData_tasksBuilder toBuilder() =>
      GTasksData_tasksBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTasksData_tasks &&
        G__typename == other.G__typename &&
        edges == other.edges &&
        pageInfo == other.pageInfo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, edges.hashCode);
    _$hash = $jc(_$hash, pageInfo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTasksData_tasks')
          ..add('G__typename', G__typename)
          ..add('edges', edges)
          ..add('pageInfo', pageInfo))
        .toString();
  }
}

class GTasksData_tasksBuilder
    implements Builder<GTasksData_tasks, GTasksData_tasksBuilder> {
  _$GTasksData_tasks? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  ListBuilder<GTasksData_tasks_edges>? _edges;
  ListBuilder<GTasksData_tasks_edges> get edges =>
      _$this._edges ??= ListBuilder<GTasksData_tasks_edges>();
  set edges(ListBuilder<GTasksData_tasks_edges>? edges) =>
      _$this._edges = edges;

  GTasksData_tasks_pageInfoBuilder? _pageInfo;
  GTasksData_tasks_pageInfoBuilder get pageInfo =>
      _$this._pageInfo ??= GTasksData_tasks_pageInfoBuilder();
  set pageInfo(GTasksData_tasks_pageInfoBuilder? pageInfo) =>
      _$this._pageInfo = pageInfo;

  GTasksData_tasksBuilder() {
    GTasksData_tasks._initializeBuilder(this);
  }

  GTasksData_tasksBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _edges = $v.edges.toBuilder();
      _pageInfo = $v.pageInfo.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTasksData_tasks other) {
    _$v = other as _$GTasksData_tasks;
  }

  @override
  void update(void Function(GTasksData_tasksBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTasksData_tasks build() => _build();

  _$GTasksData_tasks _build() {
    _$GTasksData_tasks _$result;
    try {
      _$result = _$v ??
          _$GTasksData_tasks._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GTasksData_tasks', 'G__typename'),
            edges: edges.build(),
            pageInfo: pageInfo.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'edges';
        edges.build();
        _$failedField = 'pageInfo';
        pageInfo.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GTasksData_tasks', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTasksData_tasks_edges extends GTasksData_tasks_edges {
  @override
  final String G__typename;
  @override
  final GTasksData_tasks_edges_node node;

  factory _$GTasksData_tasks_edges(
          [void Function(GTasksData_tasks_edgesBuilder)? updates]) =>
      (GTasksData_tasks_edgesBuilder()..update(updates))._build();

  _$GTasksData_tasks_edges._({required this.G__typename, required this.node})
      : super._();
  @override
  GTasksData_tasks_edges rebuild(
          void Function(GTasksData_tasks_edgesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTasksData_tasks_edgesBuilder toBuilder() =>
      GTasksData_tasks_edgesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTasksData_tasks_edges &&
        G__typename == other.G__typename &&
        node == other.node;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, node.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTasksData_tasks_edges')
          ..add('G__typename', G__typename)
          ..add('node', node))
        .toString();
  }
}

class GTasksData_tasks_edgesBuilder
    implements Builder<GTasksData_tasks_edges, GTasksData_tasks_edgesBuilder> {
  _$GTasksData_tasks_edges? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GTasksData_tasks_edges_nodeBuilder? _node;
  GTasksData_tasks_edges_nodeBuilder get node =>
      _$this._node ??= GTasksData_tasks_edges_nodeBuilder();
  set node(GTasksData_tasks_edges_nodeBuilder? node) => _$this._node = node;

  GTasksData_tasks_edgesBuilder() {
    GTasksData_tasks_edges._initializeBuilder(this);
  }

  GTasksData_tasks_edgesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _node = $v.node.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTasksData_tasks_edges other) {
    _$v = other as _$GTasksData_tasks_edges;
  }

  @override
  void update(void Function(GTasksData_tasks_edgesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTasksData_tasks_edges build() => _build();

  _$GTasksData_tasks_edges _build() {
    _$GTasksData_tasks_edges _$result;
    try {
      _$result = _$v ??
          _$GTasksData_tasks_edges._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GTasksData_tasks_edges', 'G__typename'),
            node: node.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'node';
        node.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GTasksData_tasks_edges', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTasksData_tasks_edges_node extends GTasksData_tasks_edges_node {
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
  final GTasksData_tasks_edges_node_openAssignment? openAssignment;
  @override
  final BuiltList<GTasksData_tasks_edges_node_stageSlots> stageSlots;

  factory _$GTasksData_tasks_edges_node(
          [void Function(GTasksData_tasks_edges_nodeBuilder)? updates]) =>
      (GTasksData_tasks_edges_nodeBuilder()..update(updates))._build();

  _$GTasksData_tasks_edges_node._(
      {required this.G__typename,
      required this.id,
      required this.shortId,
      required this.title,
      required this.state,
      required this.currentStage,
      required this.autonomy,
      this.openAssignment,
      required this.stageSlots})
      : super._();
  @override
  GTasksData_tasks_edges_node rebuild(
          void Function(GTasksData_tasks_edges_nodeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTasksData_tasks_edges_nodeBuilder toBuilder() =>
      GTasksData_tasks_edges_nodeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTasksData_tasks_edges_node &&
        G__typename == other.G__typename &&
        id == other.id &&
        shortId == other.shortId &&
        title == other.title &&
        state == other.state &&
        currentStage == other.currentStage &&
        autonomy == other.autonomy &&
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
    _$hash = $jc(_$hash, openAssignment.hashCode);
    _$hash = $jc(_$hash, stageSlots.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTasksData_tasks_edges_node')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('shortId', shortId)
          ..add('title', title)
          ..add('state', state)
          ..add('currentStage', currentStage)
          ..add('autonomy', autonomy)
          ..add('openAssignment', openAssignment)
          ..add('stageSlots', stageSlots))
        .toString();
  }
}

class GTasksData_tasks_edges_nodeBuilder
    implements
        Builder<GTasksData_tasks_edges_node,
            GTasksData_tasks_edges_nodeBuilder> {
  _$GTasksData_tasks_edges_node? _$v;

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

  GTasksData_tasks_edges_node_openAssignmentBuilder? _openAssignment;
  GTasksData_tasks_edges_node_openAssignmentBuilder get openAssignment =>
      _$this._openAssignment ??=
          GTasksData_tasks_edges_node_openAssignmentBuilder();
  set openAssignment(
          GTasksData_tasks_edges_node_openAssignmentBuilder? openAssignment) =>
      _$this._openAssignment = openAssignment;

  ListBuilder<GTasksData_tasks_edges_node_stageSlots>? _stageSlots;
  ListBuilder<GTasksData_tasks_edges_node_stageSlots> get stageSlots =>
      _$this._stageSlots ??=
          ListBuilder<GTasksData_tasks_edges_node_stageSlots>();
  set stageSlots(
          ListBuilder<GTasksData_tasks_edges_node_stageSlots>? stageSlots) =>
      _$this._stageSlots = stageSlots;

  GTasksData_tasks_edges_nodeBuilder() {
    GTasksData_tasks_edges_node._initializeBuilder(this);
  }

  GTasksData_tasks_edges_nodeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _shortId = $v.shortId;
      _title = $v.title;
      _state = $v.state;
      _currentStage = $v.currentStage;
      _autonomy = $v.autonomy;
      _openAssignment = $v.openAssignment?.toBuilder();
      _stageSlots = $v.stageSlots.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTasksData_tasks_edges_node other) {
    _$v = other as _$GTasksData_tasks_edges_node;
  }

  @override
  void update(void Function(GTasksData_tasks_edges_nodeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTasksData_tasks_edges_node build() => _build();

  _$GTasksData_tasks_edges_node _build() {
    _$GTasksData_tasks_edges_node _$result;
    try {
      _$result = _$v ??
          _$GTasksData_tasks_edges_node._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GTasksData_tasks_edges_node', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GTasksData_tasks_edges_node', 'id'),
            shortId: BuiltValueNullFieldError.checkNotNull(
                shortId, r'GTasksData_tasks_edges_node', 'shortId'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'GTasksData_tasks_edges_node', 'title'),
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'GTasksData_tasks_edges_node', 'state'),
            currentStage: BuiltValueNullFieldError.checkNotNull(
                currentStage, r'GTasksData_tasks_edges_node', 'currentStage'),
            autonomy: BuiltValueNullFieldError.checkNotNull(
                autonomy, r'GTasksData_tasks_edges_node', 'autonomy'),
            openAssignment: _openAssignment?.build(),
            stageSlots: stageSlots.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'openAssignment';
        _openAssignment?.build();
        _$failedField = 'stageSlots';
        stageSlots.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GTasksData_tasks_edges_node', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTasksData_tasks_edges_node_openAssignment
    extends GTasksData_tasks_edges_node_openAssignment {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GTasksData_tasks_edges_node_openAssignment(
          [void Function(GTasksData_tasks_edges_node_openAssignmentBuilder)?
              updates]) =>
      (GTasksData_tasks_edges_node_openAssignmentBuilder()..update(updates))
          ._build();

  _$GTasksData_tasks_edges_node_openAssignment._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GTasksData_tasks_edges_node_openAssignment rebuild(
          void Function(GTasksData_tasks_edges_node_openAssignmentBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTasksData_tasks_edges_node_openAssignmentBuilder toBuilder() =>
      GTasksData_tasks_edges_node_openAssignmentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTasksData_tasks_edges_node_openAssignment &&
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
            r'GTasksData_tasks_edges_node_openAssignment')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GTasksData_tasks_edges_node_openAssignmentBuilder
    implements
        Builder<GTasksData_tasks_edges_node_openAssignment,
            GTasksData_tasks_edges_node_openAssignmentBuilder> {
  _$GTasksData_tasks_edges_node_openAssignment? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GTasksData_tasks_edges_node_openAssignmentBuilder() {
    GTasksData_tasks_edges_node_openAssignment._initializeBuilder(this);
  }

  GTasksData_tasks_edges_node_openAssignmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTasksData_tasks_edges_node_openAssignment other) {
    _$v = other as _$GTasksData_tasks_edges_node_openAssignment;
  }

  @override
  void update(
      void Function(GTasksData_tasks_edges_node_openAssignmentBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GTasksData_tasks_edges_node_openAssignment build() => _build();

  _$GTasksData_tasks_edges_node_openAssignment _build() {
    final _$result = _$v ??
        _$GTasksData_tasks_edges_node_openAssignment._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GTasksData_tasks_edges_node_openAssignment', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTasksData_tasks_edges_node_openAssignment', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GTasksData_tasks_edges_node_stageSlots
    extends GTasksData_tasks_edges_node_stageSlots {
  @override
  final String G__typename;
  @override
  final _i2.GAgentStage stage;
  @override
  final bool isHuman;
  @override
  final GTasksData_tasks_edges_node_stageSlots_occupant? occupant;

  factory _$GTasksData_tasks_edges_node_stageSlots(
          [void Function(GTasksData_tasks_edges_node_stageSlotsBuilder)?
              updates]) =>
      (GTasksData_tasks_edges_node_stageSlotsBuilder()..update(updates))
          ._build();

  _$GTasksData_tasks_edges_node_stageSlots._(
      {required this.G__typename,
      required this.stage,
      required this.isHuman,
      this.occupant})
      : super._();
  @override
  GTasksData_tasks_edges_node_stageSlots rebuild(
          void Function(GTasksData_tasks_edges_node_stageSlotsBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTasksData_tasks_edges_node_stageSlotsBuilder toBuilder() =>
      GTasksData_tasks_edges_node_stageSlotsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTasksData_tasks_edges_node_stageSlots &&
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
            r'GTasksData_tasks_edges_node_stageSlots')
          ..add('G__typename', G__typename)
          ..add('stage', stage)
          ..add('isHuman', isHuman)
          ..add('occupant', occupant))
        .toString();
  }
}

class GTasksData_tasks_edges_node_stageSlotsBuilder
    implements
        Builder<GTasksData_tasks_edges_node_stageSlots,
            GTasksData_tasks_edges_node_stageSlotsBuilder> {
  _$GTasksData_tasks_edges_node_stageSlots? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  _i2.GAgentStage? _stage;
  _i2.GAgentStage? get stage => _$this._stage;
  set stage(_i2.GAgentStage? stage) => _$this._stage = stage;

  bool? _isHuman;
  bool? get isHuman => _$this._isHuman;
  set isHuman(bool? isHuman) => _$this._isHuman = isHuman;

  GTasksData_tasks_edges_node_stageSlots_occupantBuilder? _occupant;
  GTasksData_tasks_edges_node_stageSlots_occupantBuilder get occupant =>
      _$this._occupant ??=
          GTasksData_tasks_edges_node_stageSlots_occupantBuilder();
  set occupant(
          GTasksData_tasks_edges_node_stageSlots_occupantBuilder? occupant) =>
      _$this._occupant = occupant;

  GTasksData_tasks_edges_node_stageSlotsBuilder() {
    GTasksData_tasks_edges_node_stageSlots._initializeBuilder(this);
  }

  GTasksData_tasks_edges_node_stageSlotsBuilder get _$this {
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
  void replace(GTasksData_tasks_edges_node_stageSlots other) {
    _$v = other as _$GTasksData_tasks_edges_node_stageSlots;
  }

  @override
  void update(
      void Function(GTasksData_tasks_edges_node_stageSlotsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTasksData_tasks_edges_node_stageSlots build() => _build();

  _$GTasksData_tasks_edges_node_stageSlots _build() {
    _$GTasksData_tasks_edges_node_stageSlots _$result;
    try {
      _$result = _$v ??
          _$GTasksData_tasks_edges_node_stageSlots._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GTasksData_tasks_edges_node_stageSlots', 'G__typename'),
            stage: BuiltValueNullFieldError.checkNotNull(
                stage, r'GTasksData_tasks_edges_node_stageSlots', 'stage'),
            isHuman: BuiltValueNullFieldError.checkNotNull(
                isHuman, r'GTasksData_tasks_edges_node_stageSlots', 'isHuman'),
            occupant: _occupant?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'occupant';
        _occupant?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GTasksData_tasks_edges_node_stageSlots',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTasksData_tasks_edges_node_stageSlots_occupant
    extends GTasksData_tasks_edges_node_stageSlots_occupant {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String name;
  @override
  final String? model;

  factory _$GTasksData_tasks_edges_node_stageSlots_occupant(
          [void Function(
                  GTasksData_tasks_edges_node_stageSlots_occupantBuilder)?
              updates]) =>
      (GTasksData_tasks_edges_node_stageSlots_occupantBuilder()
            ..update(updates))
          ._build();

  _$GTasksData_tasks_edges_node_stageSlots_occupant._(
      {required this.G__typename,
      required this.id,
      required this.name,
      this.model})
      : super._();
  @override
  GTasksData_tasks_edges_node_stageSlots_occupant rebuild(
          void Function(GTasksData_tasks_edges_node_stageSlots_occupantBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTasksData_tasks_edges_node_stageSlots_occupantBuilder toBuilder() =>
      GTasksData_tasks_edges_node_stageSlots_occupantBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTasksData_tasks_edges_node_stageSlots_occupant &&
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
            r'GTasksData_tasks_edges_node_stageSlots_occupant')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('name', name)
          ..add('model', model))
        .toString();
  }
}

class GTasksData_tasks_edges_node_stageSlots_occupantBuilder
    implements
        Builder<GTasksData_tasks_edges_node_stageSlots_occupant,
            GTasksData_tasks_edges_node_stageSlots_occupantBuilder> {
  _$GTasksData_tasks_edges_node_stageSlots_occupant? _$v;

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

  GTasksData_tasks_edges_node_stageSlots_occupantBuilder() {
    GTasksData_tasks_edges_node_stageSlots_occupant._initializeBuilder(this);
  }

  GTasksData_tasks_edges_node_stageSlots_occupantBuilder get _$this {
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
  void replace(GTasksData_tasks_edges_node_stageSlots_occupant other) {
    _$v = other as _$GTasksData_tasks_edges_node_stageSlots_occupant;
  }

  @override
  void update(
      void Function(GTasksData_tasks_edges_node_stageSlots_occupantBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GTasksData_tasks_edges_node_stageSlots_occupant build() => _build();

  _$GTasksData_tasks_edges_node_stageSlots_occupant _build() {
    final _$result = _$v ??
        _$GTasksData_tasks_edges_node_stageSlots_occupant._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GTasksData_tasks_edges_node_stageSlots_occupant',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTasksData_tasks_edges_node_stageSlots_occupant', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GTasksData_tasks_edges_node_stageSlots_occupant', 'name'),
          model: model,
        );
    replace(_$result);
    return _$result;
  }
}

class _$GTasksData_tasks_pageInfo extends GTasksData_tasks_pageInfo {
  @override
  final String G__typename;
  @override
  final bool hasNextPage;
  @override
  final String? endCursor;

  factory _$GTasksData_tasks_pageInfo(
          [void Function(GTasksData_tasks_pageInfoBuilder)? updates]) =>
      (GTasksData_tasks_pageInfoBuilder()..update(updates))._build();

  _$GTasksData_tasks_pageInfo._(
      {required this.G__typename, required this.hasNextPage, this.endCursor})
      : super._();
  @override
  GTasksData_tasks_pageInfo rebuild(
          void Function(GTasksData_tasks_pageInfoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTasksData_tasks_pageInfoBuilder toBuilder() =>
      GTasksData_tasks_pageInfoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTasksData_tasks_pageInfo &&
        G__typename == other.G__typename &&
        hasNextPage == other.hasNextPage &&
        endCursor == other.endCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, hasNextPage.hashCode);
    _$hash = $jc(_$hash, endCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTasksData_tasks_pageInfo')
          ..add('G__typename', G__typename)
          ..add('hasNextPage', hasNextPage)
          ..add('endCursor', endCursor))
        .toString();
  }
}

class GTasksData_tasks_pageInfoBuilder
    implements
        Builder<GTasksData_tasks_pageInfo, GTasksData_tasks_pageInfoBuilder> {
  _$GTasksData_tasks_pageInfo? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _hasNextPage;
  bool? get hasNextPage => _$this._hasNextPage;
  set hasNextPage(bool? hasNextPage) => _$this._hasNextPage = hasNextPage;

  String? _endCursor;
  String? get endCursor => _$this._endCursor;
  set endCursor(String? endCursor) => _$this._endCursor = endCursor;

  GTasksData_tasks_pageInfoBuilder() {
    GTasksData_tasks_pageInfo._initializeBuilder(this);
  }

  GTasksData_tasks_pageInfoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _hasNextPage = $v.hasNextPage;
      _endCursor = $v.endCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTasksData_tasks_pageInfo other) {
    _$v = other as _$GTasksData_tasks_pageInfo;
  }

  @override
  void update(void Function(GTasksData_tasks_pageInfoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTasksData_tasks_pageInfo build() => _build();

  _$GTasksData_tasks_pageInfo _build() {
    final _$result = _$v ??
        _$GTasksData_tasks_pageInfo._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GTasksData_tasks_pageInfo', 'G__typename'),
          hasNextPage: BuiltValueNullFieldError.checkNotNull(
              hasNextPage, r'GTasksData_tasks_pageInfo', 'hasNextPage'),
          endCursor: endCursor,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
