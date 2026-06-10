// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposed_task.req.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GAcceptProposedTaskReq> _$gAcceptProposedTaskReqSerializer =
    _$GAcceptProposedTaskReqSerializer();
Serializer<GDismissProposedTaskReq> _$gDismissProposedTaskReqSerializer =
    _$GDismissProposedTaskReqSerializer();

class _$GAcceptProposedTaskReqSerializer
    implements StructuredSerializer<GAcceptProposedTaskReq> {
  @override
  final Iterable<Type> types = const [
    GAcceptProposedTaskReq,
    _$GAcceptProposedTaskReq
  ];
  @override
  final String wireName = 'GAcceptProposedTaskReq';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAcceptProposedTaskReq object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'vars',
      serializers.serialize(object.vars,
          specifiedType: const FullType(_i3.GAcceptProposedTaskVars)),
      'operation',
      serializers.serialize(object.operation,
          specifiedType: const FullType(_i4.Operation)),
      'executeOnListen',
      serializers.serialize(object.executeOnListen,
          specifiedType: const FullType(bool)),
    ];
    Object? value;
    value = object.requestId;
    if (value != null) {
      result
        ..add('requestId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.optimisticResponse;
    if (value != null) {
      result
        ..add('optimisticResponse')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GAcceptProposedTaskData)));
    }
    value = object.updateCacheHandlerKey;
    if (value != null) {
      result
        ..add('updateCacheHandlerKey')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.updateCacheHandlerContext;
    if (value != null) {
      result
        ..add('updateCacheHandlerContext')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                Map, const [const FullType(String), const FullType(dynamic)])));
    }
    value = object.fetchPolicy;
    if (value != null) {
      result
        ..add('fetchPolicy')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i1.FetchPolicy)));
    }
    return result;
  }

  @override
  GAcceptProposedTaskReq deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAcceptProposedTaskReqBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'vars':
          result.vars.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i3.GAcceptProposedTaskVars))!
              as _i3.GAcceptProposedTaskVars);
          break;
        case 'operation':
          result.operation = serializers.deserialize(value,
              specifiedType: const FullType(_i4.Operation))! as _i4.Operation;
          break;
        case 'requestId':
          result.requestId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'optimisticResponse':
          result.optimisticResponse.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GAcceptProposedTaskData))!
              as _i2.GAcceptProposedTaskData);
          break;
        case 'updateCacheHandlerKey':
          result.updateCacheHandlerKey = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'updateCacheHandlerContext':
          result.updateCacheHandlerContext = serializers.deserialize(value,
              specifiedType: const FullType(Map, const [
                const FullType(String),
                const FullType(dynamic)
              ])) as Map<String, dynamic>?;
          break;
        case 'fetchPolicy':
          result.fetchPolicy = serializers.deserialize(value,
                  specifiedType: const FullType(_i1.FetchPolicy))
              as _i1.FetchPolicy?;
          break;
        case 'executeOnListen':
          result.executeOnListen = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GDismissProposedTaskReqSerializer
    implements StructuredSerializer<GDismissProposedTaskReq> {
  @override
  final Iterable<Type> types = const [
    GDismissProposedTaskReq,
    _$GDismissProposedTaskReq
  ];
  @override
  final String wireName = 'GDismissProposedTaskReq';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDismissProposedTaskReq object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'vars',
      serializers.serialize(object.vars,
          specifiedType: const FullType(_i3.GDismissProposedTaskVars)),
      'operation',
      serializers.serialize(object.operation,
          specifiedType: const FullType(_i4.Operation)),
      'executeOnListen',
      serializers.serialize(object.executeOnListen,
          specifiedType: const FullType(bool)),
    ];
    Object? value;
    value = object.requestId;
    if (value != null) {
      result
        ..add('requestId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.optimisticResponse;
    if (value != null) {
      result
        ..add('optimisticResponse')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GDismissProposedTaskData)));
    }
    value = object.updateCacheHandlerKey;
    if (value != null) {
      result
        ..add('updateCacheHandlerKey')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.updateCacheHandlerContext;
    if (value != null) {
      result
        ..add('updateCacheHandlerContext')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                Map, const [const FullType(String), const FullType(dynamic)])));
    }
    value = object.fetchPolicy;
    if (value != null) {
      result
        ..add('fetchPolicy')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i1.FetchPolicy)));
    }
    return result;
  }

  @override
  GDismissProposedTaskReq deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDismissProposedTaskReqBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'vars':
          result.vars.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i3.GDismissProposedTaskVars))!
              as _i3.GDismissProposedTaskVars);
          break;
        case 'operation':
          result.operation = serializers.deserialize(value,
              specifiedType: const FullType(_i4.Operation))! as _i4.Operation;
          break;
        case 'requestId':
          result.requestId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'optimisticResponse':
          result.optimisticResponse.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GDismissProposedTaskData))!
              as _i2.GDismissProposedTaskData);
          break;
        case 'updateCacheHandlerKey':
          result.updateCacheHandlerKey = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'updateCacheHandlerContext':
          result.updateCacheHandlerContext = serializers.deserialize(value,
              specifiedType: const FullType(Map, const [
                const FullType(String),
                const FullType(dynamic)
              ])) as Map<String, dynamic>?;
          break;
        case 'fetchPolicy':
          result.fetchPolicy = serializers.deserialize(value,
                  specifiedType: const FullType(_i1.FetchPolicy))
              as _i1.FetchPolicy?;
          break;
        case 'executeOnListen':
          result.executeOnListen = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GAcceptProposedTaskReq extends GAcceptProposedTaskReq {
  @override
  final _i3.GAcceptProposedTaskVars vars;
  @override
  final _i4.Operation operation;
  @override
  final String? requestId;
  @override
  final _i2.GAcceptProposedTaskData? Function(
      _i2.GAcceptProposedTaskData?, _i2.GAcceptProposedTaskData?)? updateResult;
  @override
  final _i2.GAcceptProposedTaskData? optimisticResponse;
  @override
  final String? updateCacheHandlerKey;
  @override
  final Map<String, dynamic>? updateCacheHandlerContext;
  @override
  final _i1.FetchPolicy? fetchPolicy;
  @override
  final bool executeOnListen;
  @override
  final _i4.Context? context;

  factory _$GAcceptProposedTaskReq(
          [void Function(GAcceptProposedTaskReqBuilder)? updates]) =>
      (GAcceptProposedTaskReqBuilder()..update(updates))._build();

  _$GAcceptProposedTaskReq._(
      {required this.vars,
      required this.operation,
      this.requestId,
      this.updateResult,
      this.optimisticResponse,
      this.updateCacheHandlerKey,
      this.updateCacheHandlerContext,
      this.fetchPolicy,
      required this.executeOnListen,
      this.context})
      : super._();
  @override
  GAcceptProposedTaskReq rebuild(
          void Function(GAcceptProposedTaskReqBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAcceptProposedTaskReqBuilder toBuilder() =>
      GAcceptProposedTaskReqBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAcceptProposedTaskReq &&
        vars == other.vars &&
        operation == other.operation &&
        requestId == other.requestId &&
        updateResult == other.updateResult &&
        optimisticResponse == other.optimisticResponse &&
        updateCacheHandlerKey == other.updateCacheHandlerKey &&
        updateCacheHandlerContext == other.updateCacheHandlerContext &&
        fetchPolicy == other.fetchPolicy &&
        executeOnListen == other.executeOnListen &&
        context == other.context;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, vars.hashCode);
    _$hash = $jc(_$hash, operation.hashCode);
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, updateResult.hashCode);
    _$hash = $jc(_$hash, optimisticResponse.hashCode);
    _$hash = $jc(_$hash, updateCacheHandlerKey.hashCode);
    _$hash = $jc(_$hash, updateCacheHandlerContext.hashCode);
    _$hash = $jc(_$hash, fetchPolicy.hashCode);
    _$hash = $jc(_$hash, executeOnListen.hashCode);
    _$hash = $jc(_$hash, context.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAcceptProposedTaskReq')
          ..add('vars', vars)
          ..add('operation', operation)
          ..add('requestId', requestId)
          ..add('updateResult', updateResult)
          ..add('optimisticResponse', optimisticResponse)
          ..add('updateCacheHandlerKey', updateCacheHandlerKey)
          ..add('updateCacheHandlerContext', updateCacheHandlerContext)
          ..add('fetchPolicy', fetchPolicy)
          ..add('executeOnListen', executeOnListen)
          ..add('context', context))
        .toString();
  }
}

class GAcceptProposedTaskReqBuilder
    implements Builder<GAcceptProposedTaskReq, GAcceptProposedTaskReqBuilder> {
  _$GAcceptProposedTaskReq? _$v;

  _i3.GAcceptProposedTaskVarsBuilder? _vars;
  _i3.GAcceptProposedTaskVarsBuilder get vars =>
      _$this._vars ??= _i3.GAcceptProposedTaskVarsBuilder();
  set vars(_i3.GAcceptProposedTaskVarsBuilder? vars) => _$this._vars = vars;

  _i4.Operation? _operation;
  _i4.Operation? get operation => _$this._operation;
  set operation(_i4.Operation? operation) => _$this._operation = operation;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  _i2.GAcceptProposedTaskData? Function(
          _i2.GAcceptProposedTaskData?, _i2.GAcceptProposedTaskData?)?
      _updateResult;
  _i2.GAcceptProposedTaskData? Function(
          _i2.GAcceptProposedTaskData?, _i2.GAcceptProposedTaskData?)?
      get updateResult => _$this._updateResult;
  set updateResult(
          _i2.GAcceptProposedTaskData? Function(
                  _i2.GAcceptProposedTaskData?, _i2.GAcceptProposedTaskData?)?
              updateResult) =>
      _$this._updateResult = updateResult;

  _i2.GAcceptProposedTaskDataBuilder? _optimisticResponse;
  _i2.GAcceptProposedTaskDataBuilder get optimisticResponse =>
      _$this._optimisticResponse ??= _i2.GAcceptProposedTaskDataBuilder();
  set optimisticResponse(
          _i2.GAcceptProposedTaskDataBuilder? optimisticResponse) =>
      _$this._optimisticResponse = optimisticResponse;

  String? _updateCacheHandlerKey;
  String? get updateCacheHandlerKey => _$this._updateCacheHandlerKey;
  set updateCacheHandlerKey(String? updateCacheHandlerKey) =>
      _$this._updateCacheHandlerKey = updateCacheHandlerKey;

  Map<String, dynamic>? _updateCacheHandlerContext;
  Map<String, dynamic>? get updateCacheHandlerContext =>
      _$this._updateCacheHandlerContext;
  set updateCacheHandlerContext(
          Map<String, dynamic>? updateCacheHandlerContext) =>
      _$this._updateCacheHandlerContext = updateCacheHandlerContext;

  _i1.FetchPolicy? _fetchPolicy;
  _i1.FetchPolicy? get fetchPolicy => _$this._fetchPolicy;
  set fetchPolicy(_i1.FetchPolicy? fetchPolicy) =>
      _$this._fetchPolicy = fetchPolicy;

  bool? _executeOnListen;
  bool? get executeOnListen => _$this._executeOnListen;
  set executeOnListen(bool? executeOnListen) =>
      _$this._executeOnListen = executeOnListen;

  _i4.Context? _context;
  _i4.Context? get context => _$this._context;
  set context(_i4.Context? context) => _$this._context = context;

  GAcceptProposedTaskReqBuilder() {
    GAcceptProposedTaskReq._initializeBuilder(this);
  }

  GAcceptProposedTaskReqBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _vars = $v.vars.toBuilder();
      _operation = $v.operation;
      _requestId = $v.requestId;
      _updateResult = $v.updateResult;
      _optimisticResponse = $v.optimisticResponse?.toBuilder();
      _updateCacheHandlerKey = $v.updateCacheHandlerKey;
      _updateCacheHandlerContext = $v.updateCacheHandlerContext;
      _fetchPolicy = $v.fetchPolicy;
      _executeOnListen = $v.executeOnListen;
      _context = $v.context;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAcceptProposedTaskReq other) {
    _$v = other as _$GAcceptProposedTaskReq;
  }

  @override
  void update(void Function(GAcceptProposedTaskReqBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAcceptProposedTaskReq build() => _build();

  _$GAcceptProposedTaskReq _build() {
    _$GAcceptProposedTaskReq _$result;
    try {
      _$result = _$v ??
          _$GAcceptProposedTaskReq._(
            vars: vars.build(),
            operation: BuiltValueNullFieldError.checkNotNull(
                operation, r'GAcceptProposedTaskReq', 'operation'),
            requestId: requestId,
            updateResult: updateResult,
            optimisticResponse: _optimisticResponse?.build(),
            updateCacheHandlerKey: updateCacheHandlerKey,
            updateCacheHandlerContext: updateCacheHandlerContext,
            fetchPolicy: fetchPolicy,
            executeOnListen: BuiltValueNullFieldError.checkNotNull(
                executeOnListen, r'GAcceptProposedTaskReq', 'executeOnListen'),
            context: context,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'vars';
        vars.build();

        _$failedField = 'optimisticResponse';
        _optimisticResponse?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GAcceptProposedTaskReq', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GDismissProposedTaskReq extends GDismissProposedTaskReq {
  @override
  final _i3.GDismissProposedTaskVars vars;
  @override
  final _i4.Operation operation;
  @override
  final String? requestId;
  @override
  final _i2.GDismissProposedTaskData? Function(
          _i2.GDismissProposedTaskData?, _i2.GDismissProposedTaskData?)?
      updateResult;
  @override
  final _i2.GDismissProposedTaskData? optimisticResponse;
  @override
  final String? updateCacheHandlerKey;
  @override
  final Map<String, dynamic>? updateCacheHandlerContext;
  @override
  final _i1.FetchPolicy? fetchPolicy;
  @override
  final bool executeOnListen;
  @override
  final _i4.Context? context;

  factory _$GDismissProposedTaskReq(
          [void Function(GDismissProposedTaskReqBuilder)? updates]) =>
      (GDismissProposedTaskReqBuilder()..update(updates))._build();

  _$GDismissProposedTaskReq._(
      {required this.vars,
      required this.operation,
      this.requestId,
      this.updateResult,
      this.optimisticResponse,
      this.updateCacheHandlerKey,
      this.updateCacheHandlerContext,
      this.fetchPolicy,
      required this.executeOnListen,
      this.context})
      : super._();
  @override
  GDismissProposedTaskReq rebuild(
          void Function(GDismissProposedTaskReqBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDismissProposedTaskReqBuilder toBuilder() =>
      GDismissProposedTaskReqBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDismissProposedTaskReq &&
        vars == other.vars &&
        operation == other.operation &&
        requestId == other.requestId &&
        updateResult == other.updateResult &&
        optimisticResponse == other.optimisticResponse &&
        updateCacheHandlerKey == other.updateCacheHandlerKey &&
        updateCacheHandlerContext == other.updateCacheHandlerContext &&
        fetchPolicy == other.fetchPolicy &&
        executeOnListen == other.executeOnListen &&
        context == other.context;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, vars.hashCode);
    _$hash = $jc(_$hash, operation.hashCode);
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, updateResult.hashCode);
    _$hash = $jc(_$hash, optimisticResponse.hashCode);
    _$hash = $jc(_$hash, updateCacheHandlerKey.hashCode);
    _$hash = $jc(_$hash, updateCacheHandlerContext.hashCode);
    _$hash = $jc(_$hash, fetchPolicy.hashCode);
    _$hash = $jc(_$hash, executeOnListen.hashCode);
    _$hash = $jc(_$hash, context.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GDismissProposedTaskReq')
          ..add('vars', vars)
          ..add('operation', operation)
          ..add('requestId', requestId)
          ..add('updateResult', updateResult)
          ..add('optimisticResponse', optimisticResponse)
          ..add('updateCacheHandlerKey', updateCacheHandlerKey)
          ..add('updateCacheHandlerContext', updateCacheHandlerContext)
          ..add('fetchPolicy', fetchPolicy)
          ..add('executeOnListen', executeOnListen)
          ..add('context', context))
        .toString();
  }
}

class GDismissProposedTaskReqBuilder
    implements
        Builder<GDismissProposedTaskReq, GDismissProposedTaskReqBuilder> {
  _$GDismissProposedTaskReq? _$v;

  _i3.GDismissProposedTaskVarsBuilder? _vars;
  _i3.GDismissProposedTaskVarsBuilder get vars =>
      _$this._vars ??= _i3.GDismissProposedTaskVarsBuilder();
  set vars(_i3.GDismissProposedTaskVarsBuilder? vars) => _$this._vars = vars;

  _i4.Operation? _operation;
  _i4.Operation? get operation => _$this._operation;
  set operation(_i4.Operation? operation) => _$this._operation = operation;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  _i2.GDismissProposedTaskData? Function(
          _i2.GDismissProposedTaskData?, _i2.GDismissProposedTaskData?)?
      _updateResult;
  _i2.GDismissProposedTaskData? Function(
          _i2.GDismissProposedTaskData?, _i2.GDismissProposedTaskData?)?
      get updateResult => _$this._updateResult;
  set updateResult(
          _i2.GDismissProposedTaskData? Function(
                  _i2.GDismissProposedTaskData?, _i2.GDismissProposedTaskData?)?
              updateResult) =>
      _$this._updateResult = updateResult;

  _i2.GDismissProposedTaskDataBuilder? _optimisticResponse;
  _i2.GDismissProposedTaskDataBuilder get optimisticResponse =>
      _$this._optimisticResponse ??= _i2.GDismissProposedTaskDataBuilder();
  set optimisticResponse(
          _i2.GDismissProposedTaskDataBuilder? optimisticResponse) =>
      _$this._optimisticResponse = optimisticResponse;

  String? _updateCacheHandlerKey;
  String? get updateCacheHandlerKey => _$this._updateCacheHandlerKey;
  set updateCacheHandlerKey(String? updateCacheHandlerKey) =>
      _$this._updateCacheHandlerKey = updateCacheHandlerKey;

  Map<String, dynamic>? _updateCacheHandlerContext;
  Map<String, dynamic>? get updateCacheHandlerContext =>
      _$this._updateCacheHandlerContext;
  set updateCacheHandlerContext(
          Map<String, dynamic>? updateCacheHandlerContext) =>
      _$this._updateCacheHandlerContext = updateCacheHandlerContext;

  _i1.FetchPolicy? _fetchPolicy;
  _i1.FetchPolicy? get fetchPolicy => _$this._fetchPolicy;
  set fetchPolicy(_i1.FetchPolicy? fetchPolicy) =>
      _$this._fetchPolicy = fetchPolicy;

  bool? _executeOnListen;
  bool? get executeOnListen => _$this._executeOnListen;
  set executeOnListen(bool? executeOnListen) =>
      _$this._executeOnListen = executeOnListen;

  _i4.Context? _context;
  _i4.Context? get context => _$this._context;
  set context(_i4.Context? context) => _$this._context = context;

  GDismissProposedTaskReqBuilder() {
    GDismissProposedTaskReq._initializeBuilder(this);
  }

  GDismissProposedTaskReqBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _vars = $v.vars.toBuilder();
      _operation = $v.operation;
      _requestId = $v.requestId;
      _updateResult = $v.updateResult;
      _optimisticResponse = $v.optimisticResponse?.toBuilder();
      _updateCacheHandlerKey = $v.updateCacheHandlerKey;
      _updateCacheHandlerContext = $v.updateCacheHandlerContext;
      _fetchPolicy = $v.fetchPolicy;
      _executeOnListen = $v.executeOnListen;
      _context = $v.context;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDismissProposedTaskReq other) {
    _$v = other as _$GDismissProposedTaskReq;
  }

  @override
  void update(void Function(GDismissProposedTaskReqBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDismissProposedTaskReq build() => _build();

  _$GDismissProposedTaskReq _build() {
    _$GDismissProposedTaskReq _$result;
    try {
      _$result = _$v ??
          _$GDismissProposedTaskReq._(
            vars: vars.build(),
            operation: BuiltValueNullFieldError.checkNotNull(
                operation, r'GDismissProposedTaskReq', 'operation'),
            requestId: requestId,
            updateResult: updateResult,
            optimisticResponse: _optimisticResponse?.build(),
            updateCacheHandlerKey: updateCacheHandlerKey,
            updateCacheHandlerContext: updateCacheHandlerContext,
            fetchPolicy: fetchPolicy,
            executeOnListen: BuiltValueNullFieldError.checkNotNull(
                executeOnListen, r'GDismissProposedTaskReq', 'executeOnListen'),
            context: context,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'vars';
        vars.build();

        _$failedField = 'optimisticResponse';
        _optimisticResponse?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GDismissProposedTaskReq', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
