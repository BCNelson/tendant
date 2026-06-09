// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GPendingDecisionVars> _$gPendingDecisionVarsSerializer =
    _$GPendingDecisionVarsSerializer();
Serializer<GApproveArtifactVars> _$gApproveArtifactVarsSerializer =
    _$GApproveArtifactVarsSerializer();
Serializer<GRejectApprovalVars> _$gRejectApprovalVarsSerializer =
    _$GRejectApprovalVarsSerializer();
Serializer<GAnswerQuestionVars> _$gAnswerQuestionVarsSerializer =
    _$GAnswerQuestionVarsSerializer();

class _$GPendingDecisionVarsSerializer
    implements StructuredSerializer<GPendingDecisionVars> {
  @override
  final Iterable<Type> types = const [
    GPendingDecisionVars,
    _$GPendingDecisionVars
  ];
  @override
  final String wireName = 'GPendingDecisionVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GPendingDecisionVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GPendingDecisionVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GPendingDecisionVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GApproveArtifactVarsSerializer
    implements StructuredSerializer<GApproveArtifactVars> {
  @override
  final Iterable<Type> types = const [
    GApproveArtifactVars,
    _$GApproveArtifactVars
  ];
  @override
  final String wireName = 'GApproveArtifactVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GApproveArtifactVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'decisionId',
      serializers.serialize(object.decisionId,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GApproveArtifactVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GApproveArtifactVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'decisionId':
          result.decisionId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GRejectApprovalVarsSerializer
    implements StructuredSerializer<GRejectApprovalVars> {
  @override
  final Iterable<Type> types = const [
    GRejectApprovalVars,
    _$GRejectApprovalVars
  ];
  @override
  final String wireName = 'GRejectApprovalVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GRejectApprovalVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'decisionId',
      serializers.serialize(object.decisionId,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.reason;
    if (value != null) {
      result
        ..add('reason')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GRejectApprovalVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GRejectApprovalVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'decisionId':
          result.decisionId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'reason':
          result.reason = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GAnswerQuestionVarsSerializer
    implements StructuredSerializer<GAnswerQuestionVars> {
  @override
  final Iterable<Type> types = const [
    GAnswerQuestionVars,
    _$GAnswerQuestionVars
  ];
  @override
  final String wireName = 'GAnswerQuestionVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAnswerQuestionVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'decisionId',
      serializers.serialize(object.decisionId,
          specifiedType: const FullType(String)),
      'answer',
      serializers.serialize(object.answer,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GAnswerQuestionVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAnswerQuestionVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'decisionId':
          result.decisionId = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'answer':
          result.answer = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GPendingDecisionVars extends GPendingDecisionVars {
  @override
  final String id;

  factory _$GPendingDecisionVars(
          [void Function(GPendingDecisionVarsBuilder)? updates]) =>
      (GPendingDecisionVarsBuilder()..update(updates))._build();

  _$GPendingDecisionVars._({required this.id}) : super._();
  @override
  GPendingDecisionVars rebuild(
          void Function(GPendingDecisionVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPendingDecisionVarsBuilder toBuilder() =>
      GPendingDecisionVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GPendingDecisionVars && id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GPendingDecisionVars')..add('id', id))
        .toString();
  }
}

class GPendingDecisionVarsBuilder
    implements Builder<GPendingDecisionVars, GPendingDecisionVarsBuilder> {
  _$GPendingDecisionVars? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GPendingDecisionVarsBuilder();

  GPendingDecisionVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GPendingDecisionVars other) {
    _$v = other as _$GPendingDecisionVars;
  }

  @override
  void update(void Function(GPendingDecisionVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GPendingDecisionVars build() => _build();

  _$GPendingDecisionVars _build() {
    final _$result = _$v ??
        _$GPendingDecisionVars._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GPendingDecisionVars', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GApproveArtifactVars extends GApproveArtifactVars {
  @override
  final String decisionId;

  factory _$GApproveArtifactVars(
          [void Function(GApproveArtifactVarsBuilder)? updates]) =>
      (GApproveArtifactVarsBuilder()..update(updates))._build();

  _$GApproveArtifactVars._({required this.decisionId}) : super._();
  @override
  GApproveArtifactVars rebuild(
          void Function(GApproveArtifactVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GApproveArtifactVarsBuilder toBuilder() =>
      GApproveArtifactVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GApproveArtifactVars && decisionId == other.decisionId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, decisionId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GApproveArtifactVars')
          ..add('decisionId', decisionId))
        .toString();
  }
}

class GApproveArtifactVarsBuilder
    implements Builder<GApproveArtifactVars, GApproveArtifactVarsBuilder> {
  _$GApproveArtifactVars? _$v;

  String? _decisionId;
  String? get decisionId => _$this._decisionId;
  set decisionId(String? decisionId) => _$this._decisionId = decisionId;

  GApproveArtifactVarsBuilder();

  GApproveArtifactVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _decisionId = $v.decisionId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GApproveArtifactVars other) {
    _$v = other as _$GApproveArtifactVars;
  }

  @override
  void update(void Function(GApproveArtifactVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GApproveArtifactVars build() => _build();

  _$GApproveArtifactVars _build() {
    final _$result = _$v ??
        _$GApproveArtifactVars._(
          decisionId: BuiltValueNullFieldError.checkNotNull(
              decisionId, r'GApproveArtifactVars', 'decisionId'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GRejectApprovalVars extends GRejectApprovalVars {
  @override
  final String decisionId;
  @override
  final String? reason;

  factory _$GRejectApprovalVars(
          [void Function(GRejectApprovalVarsBuilder)? updates]) =>
      (GRejectApprovalVarsBuilder()..update(updates))._build();

  _$GRejectApprovalVars._({required this.decisionId, this.reason}) : super._();
  @override
  GRejectApprovalVars rebuild(
          void Function(GRejectApprovalVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRejectApprovalVarsBuilder toBuilder() =>
      GRejectApprovalVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRejectApprovalVars &&
        decisionId == other.decisionId &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, decisionId.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRejectApprovalVars')
          ..add('decisionId', decisionId)
          ..add('reason', reason))
        .toString();
  }
}

class GRejectApprovalVarsBuilder
    implements Builder<GRejectApprovalVars, GRejectApprovalVarsBuilder> {
  _$GRejectApprovalVars? _$v;

  String? _decisionId;
  String? get decisionId => _$this._decisionId;
  set decisionId(String? decisionId) => _$this._decisionId = decisionId;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  GRejectApprovalVarsBuilder();

  GRejectApprovalVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _decisionId = $v.decisionId;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRejectApprovalVars other) {
    _$v = other as _$GRejectApprovalVars;
  }

  @override
  void update(void Function(GRejectApprovalVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRejectApprovalVars build() => _build();

  _$GRejectApprovalVars _build() {
    final _$result = _$v ??
        _$GRejectApprovalVars._(
          decisionId: BuiltValueNullFieldError.checkNotNull(
              decisionId, r'GRejectApprovalVars', 'decisionId'),
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

class _$GAnswerQuestionVars extends GAnswerQuestionVars {
  @override
  final String decisionId;
  @override
  final String answer;

  factory _$GAnswerQuestionVars(
          [void Function(GAnswerQuestionVarsBuilder)? updates]) =>
      (GAnswerQuestionVarsBuilder()..update(updates))._build();

  _$GAnswerQuestionVars._({required this.decisionId, required this.answer})
      : super._();
  @override
  GAnswerQuestionVars rebuild(
          void Function(GAnswerQuestionVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAnswerQuestionVarsBuilder toBuilder() =>
      GAnswerQuestionVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAnswerQuestionVars &&
        decisionId == other.decisionId &&
        answer == other.answer;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, decisionId.hashCode);
    _$hash = $jc(_$hash, answer.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAnswerQuestionVars')
          ..add('decisionId', decisionId)
          ..add('answer', answer))
        .toString();
  }
}

class GAnswerQuestionVarsBuilder
    implements Builder<GAnswerQuestionVars, GAnswerQuestionVarsBuilder> {
  _$GAnswerQuestionVars? _$v;

  String? _decisionId;
  String? get decisionId => _$this._decisionId;
  set decisionId(String? decisionId) => _$this._decisionId = decisionId;

  String? _answer;
  String? get answer => _$this._answer;
  set answer(String? answer) => _$this._answer = answer;

  GAnswerQuestionVarsBuilder();

  GAnswerQuestionVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _decisionId = $v.decisionId;
      _answer = $v.answer;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAnswerQuestionVars other) {
    _$v = other as _$GAnswerQuestionVars;
  }

  @override
  void update(void Function(GAnswerQuestionVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAnswerQuestionVars build() => _build();

  _$GAnswerQuestionVars _build() {
    final _$result = _$v ??
        _$GAnswerQuestionVars._(
          decisionId: BuiltValueNullFieldError.checkNotNull(
              decisionId, r'GAnswerQuestionVars', 'decisionId'),
          answer: BuiltValueNullFieldError.checkNotNull(
              answer, r'GAnswerQuestionVars', 'answer'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
