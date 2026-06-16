// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'tasks.data.gql.g.dart';

abstract class GTasksData implements Built<GTasksData, GTasksDataBuilder> {
  GTasksData._();

  factory GTasksData([void Function(GTasksDataBuilder b) updates]) =
      _$GTasksData;

  static void _initializeBuilder(GTasksDataBuilder b) =>
      b..G__typename = 'Query';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GTasksData_tasks get tasks;
  static Serializer<GTasksData> get serializer => _$gTasksDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTasksData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTasksData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTasksData.serializer,
        json,
      );
}

abstract class GTasksData_tasks
    implements Built<GTasksData_tasks, GTasksData_tasksBuilder> {
  GTasksData_tasks._();

  factory GTasksData_tasks([void Function(GTasksData_tasksBuilder b) updates]) =
      _$GTasksData_tasks;

  static void _initializeBuilder(GTasksData_tasksBuilder b) =>
      b..G__typename = 'TaskConnection';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  BuiltList<GTasksData_tasks_edges> get edges;
  GTasksData_tasks_pageInfo get pageInfo;
  static Serializer<GTasksData_tasks> get serializer =>
      _$gTasksDataTasksSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTasksData_tasks.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTasksData_tasks? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTasksData_tasks.serializer,
        json,
      );
}

abstract class GTasksData_tasks_edges
    implements Built<GTasksData_tasks_edges, GTasksData_tasks_edgesBuilder> {
  GTasksData_tasks_edges._();

  factory GTasksData_tasks_edges(
          [void Function(GTasksData_tasks_edgesBuilder b) updates]) =
      _$GTasksData_tasks_edges;

  static void _initializeBuilder(GTasksData_tasks_edgesBuilder b) =>
      b..G__typename = 'TaskEdge';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GTasksData_tasks_edges_node get node;
  static Serializer<GTasksData_tasks_edges> get serializer =>
      _$gTasksDataTasksEdgesSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTasksData_tasks_edges.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTasksData_tasks_edges? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTasksData_tasks_edges.serializer,
        json,
      );
}

abstract class GTasksData_tasks_edges_node
    implements
        Built<GTasksData_tasks_edges_node, GTasksData_tasks_edges_nodeBuilder> {
  GTasksData_tasks_edges_node._();

  factory GTasksData_tasks_edges_node(
          [void Function(GTasksData_tasks_edges_nodeBuilder b) updates]) =
      _$GTasksData_tasks_edges_node;

  static void _initializeBuilder(GTasksData_tasks_edges_nodeBuilder b) =>
      b..G__typename = 'Task';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  int get shortId;
  String get title;
  _i2.GTaskState get state;
  _i2.GChainStage get currentStage;
  _i2.GAutonomyLevel get autonomy;
  GTasksData_tasks_edges_node_openAssignment? get openAssignment;
  BuiltList<GTasksData_tasks_edges_node_stageSlots> get stageSlots;
  static Serializer<GTasksData_tasks_edges_node> get serializer =>
      _$gTasksDataTasksEdgesNodeSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTasksData_tasks_edges_node.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTasksData_tasks_edges_node? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTasksData_tasks_edges_node.serializer,
        json,
      );
}

abstract class GTasksData_tasks_edges_node_openAssignment
    implements
        Built<GTasksData_tasks_edges_node_openAssignment,
            GTasksData_tasks_edges_node_openAssignmentBuilder> {
  GTasksData_tasks_edges_node_openAssignment._();

  factory GTasksData_tasks_edges_node_openAssignment(
      [void Function(GTasksData_tasks_edges_node_openAssignmentBuilder b)
          updates]) = _$GTasksData_tasks_edges_node_openAssignment;

  static void _initializeBuilder(
          GTasksData_tasks_edges_node_openAssignmentBuilder b) =>
      b..G__typename = 'AgentAssignment';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  static Serializer<GTasksData_tasks_edges_node_openAssignment>
      get serializer => _$gTasksDataTasksEdgesNodeOpenAssignmentSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTasksData_tasks_edges_node_openAssignment.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTasksData_tasks_edges_node_openAssignment? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTasksData_tasks_edges_node_openAssignment.serializer,
        json,
      );
}

abstract class GTasksData_tasks_edges_node_stageSlots
    implements
        Built<GTasksData_tasks_edges_node_stageSlots,
            GTasksData_tasks_edges_node_stageSlotsBuilder> {
  GTasksData_tasks_edges_node_stageSlots._();

  factory GTasksData_tasks_edges_node_stageSlots(
      [void Function(GTasksData_tasks_edges_node_stageSlotsBuilder b)
          updates]) = _$GTasksData_tasks_edges_node_stageSlots;

  static void _initializeBuilder(
          GTasksData_tasks_edges_node_stageSlotsBuilder b) =>
      b..G__typename = 'StageSlot';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  _i2.GAgentStage get stage;
  bool get isHuman;
  GTasksData_tasks_edges_node_stageSlots_occupant? get occupant;
  static Serializer<GTasksData_tasks_edges_node_stageSlots> get serializer =>
      _$gTasksDataTasksEdgesNodeStageSlotsSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTasksData_tasks_edges_node_stageSlots.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTasksData_tasks_edges_node_stageSlots? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTasksData_tasks_edges_node_stageSlots.serializer,
        json,
      );
}

abstract class GTasksData_tasks_edges_node_stageSlots_occupant
    implements
        Built<GTasksData_tasks_edges_node_stageSlots_occupant,
            GTasksData_tasks_edges_node_stageSlots_occupantBuilder> {
  GTasksData_tasks_edges_node_stageSlots_occupant._();

  factory GTasksData_tasks_edges_node_stageSlots_occupant(
      [void Function(GTasksData_tasks_edges_node_stageSlots_occupantBuilder b)
          updates]) = _$GTasksData_tasks_edges_node_stageSlots_occupant;

  static void _initializeBuilder(
          GTasksData_tasks_edges_node_stageSlots_occupantBuilder b) =>
      b..G__typename = 'AgentConfigSummary';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get name;
  String? get model;
  static Serializer<GTasksData_tasks_edges_node_stageSlots_occupant>
      get serializer => _$gTasksDataTasksEdgesNodeStageSlotsOccupantSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTasksData_tasks_edges_node_stageSlots_occupant.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTasksData_tasks_edges_node_stageSlots_occupant? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTasksData_tasks_edges_node_stageSlots_occupant.serializer,
        json,
      );
}

abstract class GTasksData_tasks_pageInfo
    implements
        Built<GTasksData_tasks_pageInfo, GTasksData_tasks_pageInfoBuilder> {
  GTasksData_tasks_pageInfo._();

  factory GTasksData_tasks_pageInfo(
          [void Function(GTasksData_tasks_pageInfoBuilder b) updates]) =
      _$GTasksData_tasks_pageInfo;

  static void _initializeBuilder(GTasksData_tasks_pageInfoBuilder b) =>
      b..G__typename = 'PageInfo';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  bool get hasNextPage;
  String? get endCursor;
  static Serializer<GTasksData_tasks_pageInfo> get serializer =>
      _$gTasksDataTasksPageInfoSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTasksData_tasks_pageInfo.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTasksData_tasks_pageInfo? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTasksData_tasks_pageInfo.serializer,
        json,
      );
}
