// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/operations/__generated__/inbox_subscription.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/operations/__generated__/inbox_subscription.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/operations/__generated__/inbox_subscription.var.gql.dart'
    as _i3;

part 'inbox_subscription.req.gql.g.dart';

abstract class GInboxEntryArrivedReq
    implements
        Built<GInboxEntryArrivedReq, GInboxEntryArrivedReqBuilder>,
        _i1.OperationRequest<_i2.GInboxEntryArrivedData,
            _i3.GInboxEntryArrivedVars> {
  GInboxEntryArrivedReq._();

  factory GInboxEntryArrivedReq(
          [void Function(GInboxEntryArrivedReqBuilder b) updates]) =
      _$GInboxEntryArrivedReq;

  static void _initializeBuilder(GInboxEntryArrivedReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'InboxEntryArrived',
    )
    ..executeOnListen = true;

  @override
  _i3.GInboxEntryArrivedVars get vars;
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
  _i2.GInboxEntryArrivedData? Function(
    _i2.GInboxEntryArrivedData?,
    _i2.GInboxEntryArrivedData?,
  )? get updateResult;
  @override
  _i2.GInboxEntryArrivedData? get optimisticResponse;
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
  _i2.GInboxEntryArrivedData? parseData(Map<String, dynamic> json) =>
      _i2.GInboxEntryArrivedData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GInboxEntryArrivedData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GInboxEntryArrivedData, _i3.GInboxEntryArrivedVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GInboxEntryArrivedReq> get serializer =>
      _$gInboxEntryArrivedReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GInboxEntryArrivedReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GInboxEntryArrivedReq.serializer,
        json,
      );
}
