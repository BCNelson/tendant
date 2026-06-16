// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/operations/__generated__/inbox_state.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/operations/__generated__/inbox_state.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/operations/__generated__/inbox_state.var.gql.dart'
    as _i3;

part 'inbox_state.req.gql.g.dart';

abstract class GMarkInboxReadReq
    implements
        Built<GMarkInboxReadReq, GMarkInboxReadReqBuilder>,
        _i1.OperationRequest<_i2.GMarkInboxReadData, _i3.GMarkInboxReadVars> {
  GMarkInboxReadReq._();

  factory GMarkInboxReadReq(
          [void Function(GMarkInboxReadReqBuilder b) updates]) =
      _$GMarkInboxReadReq;

  static void _initializeBuilder(GMarkInboxReadReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'MarkInboxRead',
    )
    ..executeOnListen = true;

  @override
  _i3.GMarkInboxReadVars get vars;
  @override
  _i4.Operation get operation;
  @override
  _i4.Request get execRequest => _i4.Request(
        operation: operation,
        variables: vars.toJson(),
        context: context ?? const _i4.Context(),
      );

  @override
  String? get requestId;
  @override
  @BuiltValueField(serialize: false)
  _i2.GMarkInboxReadData? Function(
    _i2.GMarkInboxReadData?,
    _i2.GMarkInboxReadData?,
  )? get updateResult;
  @override
  _i2.GMarkInboxReadData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  @BuiltValueField(serialize: false)
  _i4.Context? get context;
  @override
  _i2.GMarkInboxReadData? parseData(Map<String, dynamic> json) =>
      _i2.GMarkInboxReadData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GMarkInboxReadData data) => data.toJson();

  @override
  _i1.OperationRequest<_i2.GMarkInboxReadData, _i3.GMarkInboxReadVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GMarkInboxReadReq> get serializer =>
      _$gMarkInboxReadReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GMarkInboxReadReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GMarkInboxReadReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GMarkInboxReadReq.serializer,
        json,
      );
}

abstract class GDismissInboxMessageReq
    implements
        Built<GDismissInboxMessageReq, GDismissInboxMessageReqBuilder>,
        _i1.OperationRequest<_i2.GDismissInboxMessageData,
            _i3.GDismissInboxMessageVars> {
  GDismissInboxMessageReq._();

  factory GDismissInboxMessageReq(
          [void Function(GDismissInboxMessageReqBuilder b) updates]) =
      _$GDismissInboxMessageReq;

  static void _initializeBuilder(GDismissInboxMessageReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'DismissInboxMessage',
    )
    ..executeOnListen = true;

  @override
  _i3.GDismissInboxMessageVars get vars;
  @override
  _i4.Operation get operation;
  @override
  _i4.Request get execRequest => _i4.Request(
        operation: operation,
        variables: vars.toJson(),
        context: context ?? const _i4.Context(),
      );

  @override
  String? get requestId;
  @override
  @BuiltValueField(serialize: false)
  _i2.GDismissInboxMessageData? Function(
    _i2.GDismissInboxMessageData?,
    _i2.GDismissInboxMessageData?,
  )? get updateResult;
  @override
  _i2.GDismissInboxMessageData? get optimisticResponse;
  @override
  String? get updateCacheHandlerKey;
  @override
  Map<String, dynamic>? get updateCacheHandlerContext;
  @override
  _i1.FetchPolicy? get fetchPolicy;
  @override
  bool get executeOnListen;
  @override
  @BuiltValueField(serialize: false)
  _i4.Context? get context;
  @override
  _i2.GDismissInboxMessageData? parseData(Map<String, dynamic> json) =>
      _i2.GDismissInboxMessageData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GDismissInboxMessageData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GDismissInboxMessageData,
      _i3.GDismissInboxMessageVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GDismissInboxMessageReq> get serializer =>
      _$gDismissInboxMessageReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GDismissInboxMessageReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDismissInboxMessageReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GDismissInboxMessageReq.serializer,
        json,
      );
}
