// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/operations/__generated__/register_device_token.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/operations/__generated__/register_device_token.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/operations/__generated__/register_device_token.var.gql.dart'
    as _i3;

part 'register_device_token.req.gql.g.dart';

abstract class GRegisterDeviceTokenReq
    implements
        Built<GRegisterDeviceTokenReq, GRegisterDeviceTokenReqBuilder>,
        _i1.OperationRequest<_i2.GRegisterDeviceTokenData,
            _i3.GRegisterDeviceTokenVars> {
  GRegisterDeviceTokenReq._();

  factory GRegisterDeviceTokenReq(
          [void Function(GRegisterDeviceTokenReqBuilder b) updates]) =
      _$GRegisterDeviceTokenReq;

  static void _initializeBuilder(GRegisterDeviceTokenReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'RegisterDeviceToken',
    )
    ..executeOnListen = true;

  @override
  _i3.GRegisterDeviceTokenVars get vars;
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
  _i2.GRegisterDeviceTokenData? Function(
    _i2.GRegisterDeviceTokenData?,
    _i2.GRegisterDeviceTokenData?,
  )? get updateResult;
  @override
  _i2.GRegisterDeviceTokenData? get optimisticResponse;
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
  _i2.GRegisterDeviceTokenData? parseData(Map<String, dynamic> json) =>
      _i2.GRegisterDeviceTokenData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GRegisterDeviceTokenData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GRegisterDeviceTokenData,
      _i3.GRegisterDeviceTokenVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GRegisterDeviceTokenReq> get serializer =>
      _$gRegisterDeviceTokenReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GRegisterDeviceTokenReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRegisterDeviceTokenReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GRegisterDeviceTokenReq.serializer,
        json,
      );
}

abstract class GUnregisterDeviceTokenReq
    implements
        Built<GUnregisterDeviceTokenReq, GUnregisterDeviceTokenReqBuilder>,
        _i1.OperationRequest<_i2.GUnregisterDeviceTokenData,
            _i3.GUnregisterDeviceTokenVars> {
  GUnregisterDeviceTokenReq._();

  factory GUnregisterDeviceTokenReq(
          [void Function(GUnregisterDeviceTokenReqBuilder b) updates]) =
      _$GUnregisterDeviceTokenReq;

  static void _initializeBuilder(GUnregisterDeviceTokenReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'UnregisterDeviceToken',
    )
    ..executeOnListen = true;

  @override
  _i3.GUnregisterDeviceTokenVars get vars;
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
  _i2.GUnregisterDeviceTokenData? Function(
    _i2.GUnregisterDeviceTokenData?,
    _i2.GUnregisterDeviceTokenData?,
  )? get updateResult;
  @override
  _i2.GUnregisterDeviceTokenData? get optimisticResponse;
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
  _i2.GUnregisterDeviceTokenData? parseData(Map<String, dynamic> json) =>
      _i2.GUnregisterDeviceTokenData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GUnregisterDeviceTokenData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GUnregisterDeviceTokenData,
      _i3.GUnregisterDeviceTokenVars> transformOperation(
          _i4.Operation Function(_i4.Operation) transform) =>
      this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GUnregisterDeviceTokenReq> get serializer =>
      _$gUnregisterDeviceTokenReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GUnregisterDeviceTokenReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUnregisterDeviceTokenReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GUnregisterDeviceTokenReq.serializer,
        json,
      );
}
