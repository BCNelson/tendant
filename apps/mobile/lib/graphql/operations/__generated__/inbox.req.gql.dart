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

abstract class GInboxFeedReq
    implements
        Built<GInboxFeedReq, GInboxFeedReqBuilder>,
        _i1.OperationRequest<_i2.GInboxFeedData, _i3.GInboxFeedVars> {
  GInboxFeedReq._();

  factory GInboxFeedReq([void Function(GInboxFeedReqBuilder b) updates]) =
      _$GInboxFeedReq;

  static void _initializeBuilder(GInboxFeedReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'InboxFeed',
    )
    ..executeOnListen = true;

  @override
  _i3.GInboxFeedVars get vars;
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
  _i2.GInboxFeedData? Function(
    _i2.GInboxFeedData?,
    _i2.GInboxFeedData?,
  )? get updateResult;
  @override
  _i2.GInboxFeedData? get optimisticResponse;
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
  _i2.GInboxFeedData? parseData(Map<String, dynamic> json) =>
      _i2.GInboxFeedData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GInboxFeedData data) => data.toJson();

  @override
  _i1.OperationRequest<_i2.GInboxFeedData, _i3.GInboxFeedVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GInboxFeedReq> get serializer => _$gInboxFeedReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GInboxFeedReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxFeedReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GInboxFeedReq.serializer,
        json,
      );
}
