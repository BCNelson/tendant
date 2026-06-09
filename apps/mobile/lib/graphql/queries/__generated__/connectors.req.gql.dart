// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:ferry_exec/ferry_exec.dart' as _i1;
import 'package:gql_exec/gql_exec.dart' as _i4;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i6;
import 'package:tendant/graphql/queries/__generated__/connectors.ast.gql.dart'
    as _i5;
import 'package:tendant/graphql/queries/__generated__/connectors.data.gql.dart'
    as _i2;
import 'package:tendant/graphql/queries/__generated__/connectors.var.gql.dart'
    as _i3;

part 'connectors.req.gql.g.dart';

abstract class GConnectorsReq
    implements
        Built<GConnectorsReq, GConnectorsReqBuilder>,
        _i1.OperationRequest<_i2.GConnectorsData, _i3.GConnectorsVars> {
  GConnectorsReq._();

  factory GConnectorsReq([void Function(GConnectorsReqBuilder b) updates]) =
      _$GConnectorsReq;

  static void _initializeBuilder(GConnectorsReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'Connectors',
    )
    ..executeOnListen = true;

  @override
  _i3.GConnectorsVars get vars;
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
  _i2.GConnectorsData? Function(
    _i2.GConnectorsData?,
    _i2.GConnectorsData?,
  )? get updateResult;
  @override
  _i2.GConnectorsData? get optimisticResponse;
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
  _i2.GConnectorsData? parseData(Map<String, dynamic> json) =>
      _i2.GConnectorsData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GConnectorsData data) => data.toJson();

  @override
  _i1.OperationRequest<_i2.GConnectorsData, _i3.GConnectorsVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GConnectorsReq> get serializer =>
      _$gConnectorsReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GConnectorsReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GConnectorsReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GConnectorsReq.serializer,
        json,
      );
}

abstract class GSetConnectorConfigReq
    implements
        Built<GSetConnectorConfigReq, GSetConnectorConfigReqBuilder>,
        _i1.OperationRequest<_i2.GSetConnectorConfigData,
            _i3.GSetConnectorConfigVars> {
  GSetConnectorConfigReq._();

  factory GSetConnectorConfigReq(
          [void Function(GSetConnectorConfigReqBuilder b) updates]) =
      _$GSetConnectorConfigReq;

  static void _initializeBuilder(GSetConnectorConfigReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'SetConnectorConfig',
    )
    ..executeOnListen = true;

  @override
  _i3.GSetConnectorConfigVars get vars;
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
  _i2.GSetConnectorConfigData? Function(
    _i2.GSetConnectorConfigData?,
    _i2.GSetConnectorConfigData?,
  )? get updateResult;
  @override
  _i2.GSetConnectorConfigData? get optimisticResponse;
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
  _i2.GSetConnectorConfigData? parseData(Map<String, dynamic> json) =>
      _i2.GSetConnectorConfigData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GSetConnectorConfigData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GSetConnectorConfigData, _i3.GSetConnectorConfigVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GSetConnectorConfigReq> get serializer =>
      _$gSetConnectorConfigReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GSetConnectorConfigReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSetConnectorConfigReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GSetConnectorConfigReq.serializer,
        json,
      );
}

abstract class GEnableConnectorReq
    implements
        Built<GEnableConnectorReq, GEnableConnectorReqBuilder>,
        _i1
        .OperationRequest<_i2.GEnableConnectorData, _i3.GEnableConnectorVars> {
  GEnableConnectorReq._();

  factory GEnableConnectorReq(
          [void Function(GEnableConnectorReqBuilder b) updates]) =
      _$GEnableConnectorReq;

  static void _initializeBuilder(GEnableConnectorReqBuilder b) => b
    ..operation = _i4.Operation(
      document: _i5.document,
      operationName: 'EnableConnector',
    )
    ..executeOnListen = true;

  @override
  _i3.GEnableConnectorVars get vars;
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
  _i2.GEnableConnectorData? Function(
    _i2.GEnableConnectorData?,
    _i2.GEnableConnectorData?,
  )? get updateResult;
  @override
  _i2.GEnableConnectorData? get optimisticResponse;
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
  _i2.GEnableConnectorData? parseData(Map<String, dynamic> json) =>
      _i2.GEnableConnectorData.fromJson(json);

  @override
  Map<String, dynamic> varsToJson() => vars.toJson();

  @override
  Map<String, dynamic> dataToJson(_i2.GEnableConnectorData data) =>
      data.toJson();

  @override
  _i1.OperationRequest<_i2.GEnableConnectorData, _i3.GEnableConnectorVars>
      transformOperation(_i4.Operation Function(_i4.Operation) transform) =>
          this.rebuild((b) => b..operation = transform(operation));

  static Serializer<GEnableConnectorReq> get serializer =>
      _$gEnableConnectorReqSerializer;

  Map<String, dynamic> toJson() => (_i6.serializers.serializeWith(
        GEnableConnectorReq.serializer,
        this,
      ) as Map<String, dynamic>);

  static GEnableConnectorReq? fromJson(Map<String, dynamic> json) =>
      _i6.serializers.deserializeWith(
        GEnableConnectorReq.serializer,
        json,
      );
}
