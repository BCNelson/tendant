// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/operations/__generated__/inbox.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/operations/__generated__/inbox.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/operations/__generated__/inbox.var.gql.dart'
    as _i3;

part 'inbox.req.gql.g.dart';

abstract class GInboxReq
    implements
        Built<GInboxReq, GInboxReqBuilder>,
        _i1.OperationRequest<_i2.GInboxData, _i3.GInboxVars> {
  GInboxReq._();

  factory GInboxReq([void Function(GInboxReqBuilder b) updates]) = _$GInboxReq;

  static void _initializeBuilder(GInboxReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'Inbox',
    )
    ..executeOnListen = true;

  @override
  _i3.GInboxVars get vars;
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
  _i2.GInboxData? Function(
    _i2.GInboxData?,
    _i2.GInboxData?,
  )? get updateResult;
  @override
  _i2.GInboxData? get optimisticResponse;
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
  _i2.GInboxData? parseData(Map<String, dynamic> json) =>
      _i2.GInboxData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GInboxData data) => data.toJson();

  @override
  _i1.OperationRequest<_i2.GInboxData, _i3.GInboxVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GInboxReq> get serializer => _$gInboxReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GInboxReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GInboxReq.serializer,
        json,
      );
}
