// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_detail.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GTaskDetailData> _$gTaskDetailDataSerializer =
    _$GTaskDetailDataSerializer();
Serializer<GTaskDetailData_task> _$gTaskDetailDataTaskSerializer =
    _$GTaskDetailData_taskSerializer();
Serializer<GTaskDetailData_task_blockedBy>
    _$gTaskDetailDataTaskBlockedBySerializer =
    _$GTaskDetailData_task_blockedBySerializer();
Serializer<GTaskDetailData_task_blocks> _$gTaskDetailDataTaskBlocksSerializer =
    _$GTaskDetailData_task_blocksSerializer();
Serializer<GTaskDetailData_task_parent> _$gTaskDetailDataTaskParentSerializer =
    _$GTaskDetailData_task_parentSerializer();
Serializer<GTaskDetailData_task_subtasks>
    _$gTaskDetailDataTaskSubtasksSerializer =
    _$GTaskDetailData_task_subtasksSerializer();
Serializer<GTaskDetailData_task_related>
    _$gTaskDetailDataTaskRelatedSerializer =
    _$GTaskDetailData_task_relatedSerializer();
Serializer<GTaskDetailData_task_duplicateOf>
    _$gTaskDetailDataTaskDuplicateOfSerializer =
    _$GTaskDetailData_task_duplicateOfSerializer();
Serializer<GTaskDetailData_task_duplicates>
    _$gTaskDetailDataTaskDuplicatesSerializer =
    _$GTaskDetailData_task_duplicatesSerializer();
Serializer<GTaskDetailData_task_stageSlots>
    _$gTaskDetailDataTaskStageSlotsSerializer =
    _$GTaskDetailData_task_stageSlotsSerializer();
Serializer<GTaskDetailData_task_stageSlots_occupant>
    _$gTaskDetailDataTaskStageSlotsOccupantSerializer =
    _$GTaskDetailData_task_stageSlots_occupantSerializer();
Serializer<GTaskDetailData_task_activity>
    _$gTaskDetailDataTaskActivitySerializer =
    _$GTaskDetailData_task_activitySerializer();
Serializer<GTaskLinkData> _$gTaskLinkDataSerializer =
    _$GTaskLinkDataSerializer();

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
      'blocked',
      serializers.serialize(object.blocked,
          specifiedType: const FullType(bool)),
      'blockedBy',
      serializers.serialize(object.blockedBy,
          specifiedType: const FullType(BuiltList,
              const [const FullType(GTaskDetailData_task_blockedBy)])),
      'blocks',
      serializers.serialize(object.blocks,
          specifiedType: const FullType(
              BuiltList, const [const FullType(GTaskDetailData_task_blocks)])),
      'subtasks',
      serializers.serialize(object.subtasks,
          specifiedType: const FullType(BuiltList,
              const [const FullType(GTaskDetailData_task_subtasks)])),
      'related',
      serializers.serialize(object.related,
          specifiedType: const FullType(
              BuiltList, const [const FullType(GTaskDetailData_task_related)])),
      'duplicates',
      serializers.serialize(object.duplicates,
          specifiedType: const FullType(BuiltList,
              const [const FullType(GTaskDetailData_task_duplicates)])),
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
    value = object.startsAt;
    if (value != null) {
      result
        ..add('startsAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    value = object.rank;
    if (value != null) {
      result
        ..add('rank')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
    }
    value = object.parent;
    if (value != null) {
      result
        ..add('parent')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GTaskDetailData_task_parent)));
    }
    value = object.duplicateOf;
    if (value != null) {
      result
        ..add('duplicateOf')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GTaskDetailData_task_duplicateOf)));
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
        case 'startsAt':
          result.startsAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'rank':
          result.rank = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
          break;
        case 'blocked':
          result.blocked = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'blockedBy':
          result.blockedBy.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GTaskDetailData_task_blockedBy)
              ]))! as BuiltList<Object?>);
          break;
        case 'blocks':
          result.blocks.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GTaskDetailData_task_blocks)
              ]))! as BuiltList<Object?>);
          break;
        case 'parent':
          result.parent.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GTaskDetailData_task_parent))!
              as GTaskDetailData_task_parent);
          break;
        case 'subtasks':
          result.subtasks.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GTaskDetailData_task_subtasks)
              ]))! as BuiltList<Object?>);
          break;
        case 'related':
          result.related.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GTaskDetailData_task_related)
              ]))! as BuiltList<Object?>);
          break;
        case 'duplicateOf':
          result.duplicateOf.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GTaskDetailData_task_duplicateOf))!
              as GTaskDetailData_task_duplicateOf);
          break;
        case 'duplicates':
          result.duplicates.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GTaskDetailData_task_duplicates)
              ]))! as BuiltList<Object?>);
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

class _$GTaskDetailData_task_blockedBySerializer
    implements StructuredSerializer<GTaskDetailData_task_blockedBy> {
  @override
  final Iterable<Type> types = const [
    GTaskDetailData_task_blockedBy,
    _$GTaskDetailData_task_blockedBy
  ];
  @override
  final String wireName = 'GTaskDetailData_task_blockedBy';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskDetailData_task_blockedBy object,
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
  GTaskDetailData_task_blockedBy deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskDetailData_task_blockedByBuilder();

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

class _$GTaskDetailData_task_blocksSerializer
    implements StructuredSerializer<GTaskDetailData_task_blocks> {
  @override
  final Iterable<Type> types = const [
    GTaskDetailData_task_blocks,
    _$GTaskDetailData_task_blocks
  ];
  @override
  final String wireName = 'GTaskDetailData_task_blocks';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskDetailData_task_blocks object,
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
  GTaskDetailData_task_blocks deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskDetailData_task_blocksBuilder();

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

class _$GTaskDetailData_task_parentSerializer
    implements StructuredSerializer<GTaskDetailData_task_parent> {
  @override
  final Iterable<Type> types = const [
    GTaskDetailData_task_parent,
    _$GTaskDetailData_task_parent
  ];
  @override
  final String wireName = 'GTaskDetailData_task_parent';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskDetailData_task_parent object,
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
  GTaskDetailData_task_parent deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskDetailData_task_parentBuilder();

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

class _$GTaskDetailData_task_subtasksSerializer
    implements StructuredSerializer<GTaskDetailData_task_subtasks> {
  @override
  final Iterable<Type> types = const [
    GTaskDetailData_task_subtasks,
    _$GTaskDetailData_task_subtasks
  ];
  @override
  final String wireName = 'GTaskDetailData_task_subtasks';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskDetailData_task_subtasks object,
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
  GTaskDetailData_task_subtasks deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskDetailData_task_subtasksBuilder();

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

class _$GTaskDetailData_task_relatedSerializer
    implements StructuredSerializer<GTaskDetailData_task_related> {
  @override
  final Iterable<Type> types = const [
    GTaskDetailData_task_related,
    _$GTaskDetailData_task_related
  ];
  @override
  final String wireName = 'GTaskDetailData_task_related';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskDetailData_task_related object,
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
  GTaskDetailData_task_related deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskDetailData_task_relatedBuilder();

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

class _$GTaskDetailData_task_duplicateOfSerializer
    implements StructuredSerializer<GTaskDetailData_task_duplicateOf> {
  @override
  final Iterable<Type> types = const [
    GTaskDetailData_task_duplicateOf,
    _$GTaskDetailData_task_duplicateOf
  ];
  @override
  final String wireName = 'GTaskDetailData_task_duplicateOf';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskDetailData_task_duplicateOf object,
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
  GTaskDetailData_task_duplicateOf deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskDetailData_task_duplicateOfBuilder();

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

class _$GTaskDetailData_task_duplicatesSerializer
    implements StructuredSerializer<GTaskDetailData_task_duplicates> {
  @override
  final Iterable<Type> types = const [
    GTaskDetailData_task_duplicates,
    _$GTaskDetailData_task_duplicates
  ];
  @override
  final String wireName = 'GTaskDetailData_task_duplicates';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GTaskDetailData_task_duplicates object,
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
  GTaskDetailData_task_duplicates deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskDetailData_task_duplicatesBuilder();

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

class _$GTaskLinkDataSerializer implements StructuredSerializer<GTaskLinkData> {
  @override
  final Iterable<Type> types = const [GTaskLinkData, _$GTaskLinkData];
  @override
  final String wireName = 'GTaskLinkData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GTaskLinkData object,
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
  GTaskLinkData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskLinkDataBuilder();

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
  final _i2.GTime? startsAt;
  @override
  final double? rank;
  @override
  final bool blocked;
  @override
  final BuiltList<GTaskDetailData_task_blockedBy> blockedBy;
  @override
  final BuiltList<GTaskDetailData_task_blocks> blocks;
  @override
  final GTaskDetailData_task_parent? parent;
  @override
  final BuiltList<GTaskDetailData_task_subtasks> subtasks;
  @override
  final BuiltList<GTaskDetailData_task_related> related;
  @override
  final GTaskDetailData_task_duplicateOf? duplicateOf;
  @override
  final BuiltList<GTaskDetailData_task_duplicates> duplicates;
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
      this.startsAt,
      this.rank,
      required this.blocked,
      required this.blockedBy,
      required this.blocks,
      this.parent,
      required this.subtasks,
      required this.related,
      this.duplicateOf,
      required this.duplicates,
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
        startsAt == other.startsAt &&
        rank == other.rank &&
        blocked == other.blocked &&
        blockedBy == other.blockedBy &&
        blocks == other.blocks &&
        parent == other.parent &&
        subtasks == other.subtasks &&
        related == other.related &&
        duplicateOf == other.duplicateOf &&
        duplicates == other.duplicates &&
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
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, rank.hashCode);
    _$hash = $jc(_$hash, blocked.hashCode);
    _$hash = $jc(_$hash, blockedBy.hashCode);
    _$hash = $jc(_$hash, blocks.hashCode);
    _$hash = $jc(_$hash, parent.hashCode);
    _$hash = $jc(_$hash, subtasks.hashCode);
    _$hash = $jc(_$hash, related.hashCode);
    _$hash = $jc(_$hash, duplicateOf.hashCode);
    _$hash = $jc(_$hash, duplicates.hashCode);
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
          ..add('startsAt', startsAt)
          ..add('rank', rank)
          ..add('blocked', blocked)
          ..add('blockedBy', blockedBy)
          ..add('blocks', blocks)
          ..add('parent', parent)
          ..add('subtasks', subtasks)
          ..add('related', related)
          ..add('duplicateOf', duplicateOf)
          ..add('duplicates', duplicates)
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

  _i2.GTimeBuilder? _startsAt;
  _i2.GTimeBuilder get startsAt => _$this._startsAt ??= _i2.GTimeBuilder();
  set startsAt(_i2.GTimeBuilder? startsAt) => _$this._startsAt = startsAt;

  double? _rank;
  double? get rank => _$this._rank;
  set rank(double? rank) => _$this._rank = rank;

  bool? _blocked;
  bool? get blocked => _$this._blocked;
  set blocked(bool? blocked) => _$this._blocked = blocked;

  ListBuilder<GTaskDetailData_task_blockedBy>? _blockedBy;
  ListBuilder<GTaskDetailData_task_blockedBy> get blockedBy =>
      _$this._blockedBy ??= ListBuilder<GTaskDetailData_task_blockedBy>();
  set blockedBy(ListBuilder<GTaskDetailData_task_blockedBy>? blockedBy) =>
      _$this._blockedBy = blockedBy;

  ListBuilder<GTaskDetailData_task_blocks>? _blocks;
  ListBuilder<GTaskDetailData_task_blocks> get blocks =>
      _$this._blocks ??= ListBuilder<GTaskDetailData_task_blocks>();
  set blocks(ListBuilder<GTaskDetailData_task_blocks>? blocks) =>
      _$this._blocks = blocks;

  GTaskDetailData_task_parentBuilder? _parent;
  GTaskDetailData_task_parentBuilder get parent =>
      _$this._parent ??= GTaskDetailData_task_parentBuilder();
  set parent(GTaskDetailData_task_parentBuilder? parent) =>
      _$this._parent = parent;

  ListBuilder<GTaskDetailData_task_subtasks>? _subtasks;
  ListBuilder<GTaskDetailData_task_subtasks> get subtasks =>
      _$this._subtasks ??= ListBuilder<GTaskDetailData_task_subtasks>();
  set subtasks(ListBuilder<GTaskDetailData_task_subtasks>? subtasks) =>
      _$this._subtasks = subtasks;

  ListBuilder<GTaskDetailData_task_related>? _related;
  ListBuilder<GTaskDetailData_task_related> get related =>
      _$this._related ??= ListBuilder<GTaskDetailData_task_related>();
  set related(ListBuilder<GTaskDetailData_task_related>? related) =>
      _$this._related = related;

  GTaskDetailData_task_duplicateOfBuilder? _duplicateOf;
  GTaskDetailData_task_duplicateOfBuilder get duplicateOf =>
      _$this._duplicateOf ??= GTaskDetailData_task_duplicateOfBuilder();
  set duplicateOf(GTaskDetailData_task_duplicateOfBuilder? duplicateOf) =>
      _$this._duplicateOf = duplicateOf;

  ListBuilder<GTaskDetailData_task_duplicates>? _duplicates;
  ListBuilder<GTaskDetailData_task_duplicates> get duplicates =>
      _$this._duplicates ??= ListBuilder<GTaskDetailData_task_duplicates>();
  set duplicates(ListBuilder<GTaskDetailData_task_duplicates>? duplicates) =>
      _$this._duplicates = duplicates;

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
      _startsAt = $v.startsAt?.toBuilder();
      _rank = $v.rank;
      _blocked = $v.blocked;
      _blockedBy = $v.blockedBy.toBuilder();
      _blocks = $v.blocks.toBuilder();
      _parent = $v.parent?.toBuilder();
      _subtasks = $v.subtasks.toBuilder();
      _related = $v.related.toBuilder();
      _duplicateOf = $v.duplicateOf?.toBuilder();
      _duplicates = $v.duplicates.toBuilder();
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
            startsAt: _startsAt?.build(),
            rank: rank,
            blocked: BuiltValueNullFieldError.checkNotNull(
                blocked, r'GTaskDetailData_task', 'blocked'),
            blockedBy: blockedBy.build(),
            blocks: blocks.build(),
            parent: _parent?.build(),
            subtasks: subtasks.build(),
            related: related.build(),
            duplicateOf: _duplicateOf?.build(),
            duplicates: duplicates.build(),
            findings: findings,
            stageSlots: stageSlots.build(),
            activity: activity.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dueAt';
        _dueAt?.build();
        _$failedField = 'startsAt';
        _startsAt?.build();

        _$failedField = 'blockedBy';
        blockedBy.build();
        _$failedField = 'blocks';
        blocks.build();
        _$failedField = 'parent';
        _parent?.build();
        _$failedField = 'subtasks';
        subtasks.build();
        _$failedField = 'related';
        related.build();
        _$failedField = 'duplicateOf';
        _duplicateOf?.build();
        _$failedField = 'duplicates';
        duplicates.build();

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

class _$GTaskDetailData_task_blockedBy extends GTaskDetailData_task_blockedBy {
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

  factory _$GTaskDetailData_task_blockedBy(
          [void Function(GTaskDetailData_task_blockedByBuilder)? updates]) =>
      (GTaskDetailData_task_blockedByBuilder()..update(updates))._build();

  _$GTaskDetailData_task_blockedBy._(
      {required this.G__typename,
      required this.id,
      required this.shortId,
      required this.title,
      required this.state})
      : super._();
  @override
  GTaskDetailData_task_blockedBy rebuild(
          void Function(GTaskDetailData_task_blockedByBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskDetailData_task_blockedByBuilder toBuilder() =>
      GTaskDetailData_task_blockedByBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskDetailData_task_blockedBy &&
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
    return (newBuiltValueToStringHelper(r'GTaskDetailData_task_blockedBy')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('shortId', shortId)
          ..add('title', title)
          ..add('state', state))
        .toString();
  }
}

class GTaskDetailData_task_blockedByBuilder
    implements
        Builder<GTaskDetailData_task_blockedBy,
            GTaskDetailData_task_blockedByBuilder> {
  _$GTaskDetailData_task_blockedBy? _$v;

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

  GTaskDetailData_task_blockedByBuilder() {
    GTaskDetailData_task_blockedBy._initializeBuilder(this);
  }

  GTaskDetailData_task_blockedByBuilder get _$this {
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
  void replace(GTaskDetailData_task_blockedBy other) {
    _$v = other as _$GTaskDetailData_task_blockedBy;
  }

  @override
  void update(void Function(GTaskDetailData_task_blockedByBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskDetailData_task_blockedBy build() => _build();

  _$GTaskDetailData_task_blockedBy _build() {
    final _$result = _$v ??
        _$GTaskDetailData_task_blockedBy._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GTaskDetailData_task_blockedBy', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTaskDetailData_task_blockedBy', 'id'),
          shortId: BuiltValueNullFieldError.checkNotNull(
              shortId, r'GTaskDetailData_task_blockedBy', 'shortId'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GTaskDetailData_task_blockedBy', 'title'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GTaskDetailData_task_blockedBy', 'state'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GTaskDetailData_task_blocks extends GTaskDetailData_task_blocks {
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

  factory _$GTaskDetailData_task_blocks(
          [void Function(GTaskDetailData_task_blocksBuilder)? updates]) =>
      (GTaskDetailData_task_blocksBuilder()..update(updates))._build();

  _$GTaskDetailData_task_blocks._(
      {required this.G__typename,
      required this.id,
      required this.shortId,
      required this.title,
      required this.state})
      : super._();
  @override
  GTaskDetailData_task_blocks rebuild(
          void Function(GTaskDetailData_task_blocksBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskDetailData_task_blocksBuilder toBuilder() =>
      GTaskDetailData_task_blocksBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskDetailData_task_blocks &&
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
    return (newBuiltValueToStringHelper(r'GTaskDetailData_task_blocks')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('shortId', shortId)
          ..add('title', title)
          ..add('state', state))
        .toString();
  }
}

class GTaskDetailData_task_blocksBuilder
    implements
        Builder<GTaskDetailData_task_blocks,
            GTaskDetailData_task_blocksBuilder> {
  _$GTaskDetailData_task_blocks? _$v;

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

  GTaskDetailData_task_blocksBuilder() {
    GTaskDetailData_task_blocks._initializeBuilder(this);
  }

  GTaskDetailData_task_blocksBuilder get _$this {
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
  void replace(GTaskDetailData_task_blocks other) {
    _$v = other as _$GTaskDetailData_task_blocks;
  }

  @override
  void update(void Function(GTaskDetailData_task_blocksBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskDetailData_task_blocks build() => _build();

  _$GTaskDetailData_task_blocks _build() {
    final _$result = _$v ??
        _$GTaskDetailData_task_blocks._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GTaskDetailData_task_blocks', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTaskDetailData_task_blocks', 'id'),
          shortId: BuiltValueNullFieldError.checkNotNull(
              shortId, r'GTaskDetailData_task_blocks', 'shortId'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GTaskDetailData_task_blocks', 'title'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GTaskDetailData_task_blocks', 'state'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GTaskDetailData_task_parent extends GTaskDetailData_task_parent {
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

  factory _$GTaskDetailData_task_parent(
          [void Function(GTaskDetailData_task_parentBuilder)? updates]) =>
      (GTaskDetailData_task_parentBuilder()..update(updates))._build();

  _$GTaskDetailData_task_parent._(
      {required this.G__typename,
      required this.id,
      required this.shortId,
      required this.title,
      required this.state})
      : super._();
  @override
  GTaskDetailData_task_parent rebuild(
          void Function(GTaskDetailData_task_parentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskDetailData_task_parentBuilder toBuilder() =>
      GTaskDetailData_task_parentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskDetailData_task_parent &&
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
    return (newBuiltValueToStringHelper(r'GTaskDetailData_task_parent')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('shortId', shortId)
          ..add('title', title)
          ..add('state', state))
        .toString();
  }
}

class GTaskDetailData_task_parentBuilder
    implements
        Builder<GTaskDetailData_task_parent,
            GTaskDetailData_task_parentBuilder> {
  _$GTaskDetailData_task_parent? _$v;

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

  GTaskDetailData_task_parentBuilder() {
    GTaskDetailData_task_parent._initializeBuilder(this);
  }

  GTaskDetailData_task_parentBuilder get _$this {
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
  void replace(GTaskDetailData_task_parent other) {
    _$v = other as _$GTaskDetailData_task_parent;
  }

  @override
  void update(void Function(GTaskDetailData_task_parentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskDetailData_task_parent build() => _build();

  _$GTaskDetailData_task_parent _build() {
    final _$result = _$v ??
        _$GTaskDetailData_task_parent._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GTaskDetailData_task_parent', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTaskDetailData_task_parent', 'id'),
          shortId: BuiltValueNullFieldError.checkNotNull(
              shortId, r'GTaskDetailData_task_parent', 'shortId'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GTaskDetailData_task_parent', 'title'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GTaskDetailData_task_parent', 'state'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GTaskDetailData_task_subtasks extends GTaskDetailData_task_subtasks {
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

  factory _$GTaskDetailData_task_subtasks(
          [void Function(GTaskDetailData_task_subtasksBuilder)? updates]) =>
      (GTaskDetailData_task_subtasksBuilder()..update(updates))._build();

  _$GTaskDetailData_task_subtasks._(
      {required this.G__typename,
      required this.id,
      required this.shortId,
      required this.title,
      required this.state})
      : super._();
  @override
  GTaskDetailData_task_subtasks rebuild(
          void Function(GTaskDetailData_task_subtasksBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskDetailData_task_subtasksBuilder toBuilder() =>
      GTaskDetailData_task_subtasksBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskDetailData_task_subtasks &&
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
    return (newBuiltValueToStringHelper(r'GTaskDetailData_task_subtasks')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('shortId', shortId)
          ..add('title', title)
          ..add('state', state))
        .toString();
  }
}

class GTaskDetailData_task_subtasksBuilder
    implements
        Builder<GTaskDetailData_task_subtasks,
            GTaskDetailData_task_subtasksBuilder> {
  _$GTaskDetailData_task_subtasks? _$v;

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

  GTaskDetailData_task_subtasksBuilder() {
    GTaskDetailData_task_subtasks._initializeBuilder(this);
  }

  GTaskDetailData_task_subtasksBuilder get _$this {
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
  void replace(GTaskDetailData_task_subtasks other) {
    _$v = other as _$GTaskDetailData_task_subtasks;
  }

  @override
  void update(void Function(GTaskDetailData_task_subtasksBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskDetailData_task_subtasks build() => _build();

  _$GTaskDetailData_task_subtasks _build() {
    final _$result = _$v ??
        _$GTaskDetailData_task_subtasks._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GTaskDetailData_task_subtasks', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTaskDetailData_task_subtasks', 'id'),
          shortId: BuiltValueNullFieldError.checkNotNull(
              shortId, r'GTaskDetailData_task_subtasks', 'shortId'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GTaskDetailData_task_subtasks', 'title'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GTaskDetailData_task_subtasks', 'state'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GTaskDetailData_task_related extends GTaskDetailData_task_related {
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

  factory _$GTaskDetailData_task_related(
          [void Function(GTaskDetailData_task_relatedBuilder)? updates]) =>
      (GTaskDetailData_task_relatedBuilder()..update(updates))._build();

  _$GTaskDetailData_task_related._(
      {required this.G__typename,
      required this.id,
      required this.shortId,
      required this.title,
      required this.state})
      : super._();
  @override
  GTaskDetailData_task_related rebuild(
          void Function(GTaskDetailData_task_relatedBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskDetailData_task_relatedBuilder toBuilder() =>
      GTaskDetailData_task_relatedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskDetailData_task_related &&
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
    return (newBuiltValueToStringHelper(r'GTaskDetailData_task_related')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('shortId', shortId)
          ..add('title', title)
          ..add('state', state))
        .toString();
  }
}

class GTaskDetailData_task_relatedBuilder
    implements
        Builder<GTaskDetailData_task_related,
            GTaskDetailData_task_relatedBuilder> {
  _$GTaskDetailData_task_related? _$v;

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

  GTaskDetailData_task_relatedBuilder() {
    GTaskDetailData_task_related._initializeBuilder(this);
  }

  GTaskDetailData_task_relatedBuilder get _$this {
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
  void replace(GTaskDetailData_task_related other) {
    _$v = other as _$GTaskDetailData_task_related;
  }

  @override
  void update(void Function(GTaskDetailData_task_relatedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskDetailData_task_related build() => _build();

  _$GTaskDetailData_task_related _build() {
    final _$result = _$v ??
        _$GTaskDetailData_task_related._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GTaskDetailData_task_related', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTaskDetailData_task_related', 'id'),
          shortId: BuiltValueNullFieldError.checkNotNull(
              shortId, r'GTaskDetailData_task_related', 'shortId'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GTaskDetailData_task_related', 'title'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GTaskDetailData_task_related', 'state'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GTaskDetailData_task_duplicateOf
    extends GTaskDetailData_task_duplicateOf {
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

  factory _$GTaskDetailData_task_duplicateOf(
          [void Function(GTaskDetailData_task_duplicateOfBuilder)? updates]) =>
      (GTaskDetailData_task_duplicateOfBuilder()..update(updates))._build();

  _$GTaskDetailData_task_duplicateOf._(
      {required this.G__typename,
      required this.id,
      required this.shortId,
      required this.title,
      required this.state})
      : super._();
  @override
  GTaskDetailData_task_duplicateOf rebuild(
          void Function(GTaskDetailData_task_duplicateOfBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskDetailData_task_duplicateOfBuilder toBuilder() =>
      GTaskDetailData_task_duplicateOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskDetailData_task_duplicateOf &&
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
    return (newBuiltValueToStringHelper(r'GTaskDetailData_task_duplicateOf')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('shortId', shortId)
          ..add('title', title)
          ..add('state', state))
        .toString();
  }
}

class GTaskDetailData_task_duplicateOfBuilder
    implements
        Builder<GTaskDetailData_task_duplicateOf,
            GTaskDetailData_task_duplicateOfBuilder> {
  _$GTaskDetailData_task_duplicateOf? _$v;

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

  GTaskDetailData_task_duplicateOfBuilder() {
    GTaskDetailData_task_duplicateOf._initializeBuilder(this);
  }

  GTaskDetailData_task_duplicateOfBuilder get _$this {
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
  void replace(GTaskDetailData_task_duplicateOf other) {
    _$v = other as _$GTaskDetailData_task_duplicateOf;
  }

  @override
  void update(void Function(GTaskDetailData_task_duplicateOfBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskDetailData_task_duplicateOf build() => _build();

  _$GTaskDetailData_task_duplicateOf _build() {
    final _$result = _$v ??
        _$GTaskDetailData_task_duplicateOf._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GTaskDetailData_task_duplicateOf', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTaskDetailData_task_duplicateOf', 'id'),
          shortId: BuiltValueNullFieldError.checkNotNull(
              shortId, r'GTaskDetailData_task_duplicateOf', 'shortId'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GTaskDetailData_task_duplicateOf', 'title'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GTaskDetailData_task_duplicateOf', 'state'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GTaskDetailData_task_duplicates
    extends GTaskDetailData_task_duplicates {
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

  factory _$GTaskDetailData_task_duplicates(
          [void Function(GTaskDetailData_task_duplicatesBuilder)? updates]) =>
      (GTaskDetailData_task_duplicatesBuilder()..update(updates))._build();

  _$GTaskDetailData_task_duplicates._(
      {required this.G__typename,
      required this.id,
      required this.shortId,
      required this.title,
      required this.state})
      : super._();
  @override
  GTaskDetailData_task_duplicates rebuild(
          void Function(GTaskDetailData_task_duplicatesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskDetailData_task_duplicatesBuilder toBuilder() =>
      GTaskDetailData_task_duplicatesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskDetailData_task_duplicates &&
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
    return (newBuiltValueToStringHelper(r'GTaskDetailData_task_duplicates')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('shortId', shortId)
          ..add('title', title)
          ..add('state', state))
        .toString();
  }
}

class GTaskDetailData_task_duplicatesBuilder
    implements
        Builder<GTaskDetailData_task_duplicates,
            GTaskDetailData_task_duplicatesBuilder> {
  _$GTaskDetailData_task_duplicates? _$v;

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

  GTaskDetailData_task_duplicatesBuilder() {
    GTaskDetailData_task_duplicates._initializeBuilder(this);
  }

  GTaskDetailData_task_duplicatesBuilder get _$this {
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
  void replace(GTaskDetailData_task_duplicates other) {
    _$v = other as _$GTaskDetailData_task_duplicates;
  }

  @override
  void update(void Function(GTaskDetailData_task_duplicatesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskDetailData_task_duplicates build() => _build();

  _$GTaskDetailData_task_duplicates _build() {
    final _$result = _$v ??
        _$GTaskDetailData_task_duplicates._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GTaskDetailData_task_duplicates', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTaskDetailData_task_duplicates', 'id'),
          shortId: BuiltValueNullFieldError.checkNotNull(
              shortId, r'GTaskDetailData_task_duplicates', 'shortId'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GTaskDetailData_task_duplicates', 'title'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GTaskDetailData_task_duplicates', 'state'),
        );
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

class _$GTaskLinkData extends GTaskLinkData {
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

  factory _$GTaskLinkData([void Function(GTaskLinkDataBuilder)? updates]) =>
      (GTaskLinkDataBuilder()..update(updates))._build();

  _$GTaskLinkData._(
      {required this.G__typename,
      required this.id,
      required this.shortId,
      required this.title,
      required this.state})
      : super._();
  @override
  GTaskLinkData rebuild(void Function(GTaskLinkDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskLinkDataBuilder toBuilder() => GTaskLinkDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskLinkData &&
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
    return (newBuiltValueToStringHelper(r'GTaskLinkData')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('shortId', shortId)
          ..add('title', title)
          ..add('state', state))
        .toString();
  }
}

class GTaskLinkDataBuilder
    implements Builder<GTaskLinkData, GTaskLinkDataBuilder> {
  _$GTaskLinkData? _$v;

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

  GTaskLinkDataBuilder() {
    GTaskLinkData._initializeBuilder(this);
  }

  GTaskLinkDataBuilder get _$this {
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
  void replace(GTaskLinkData other) {
    _$v = other as _$GTaskLinkData;
  }

  @override
  void update(void Function(GTaskLinkDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskLinkData build() => _build();

  _$GTaskLinkData _build() {
    final _$result = _$v ??
        _$GTaskLinkData._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GTaskLinkData', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'GTaskLinkData', 'id'),
          shortId: BuiltValueNullFieldError.checkNotNull(
              shortId, r'GTaskLinkData', 'shortId'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GTaskLinkData', 'title'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GTaskLinkData', 'state'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
