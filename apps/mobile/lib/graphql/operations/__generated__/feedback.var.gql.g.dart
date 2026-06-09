// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GFeedbackRequestVars> _$gFeedbackRequestVarsSerializer =
    _$GFeedbackRequestVarsSerializer();
Serializer<GSendFeedbackMessageVars> _$gSendFeedbackMessageVarsSerializer =
    _$GSendFeedbackMessageVarsSerializer();
Serializer<GAcceptFeedbackGuidanceVars>
    _$gAcceptFeedbackGuidanceVarsSerializer =
    _$GAcceptFeedbackGuidanceVarsSerializer();
Serializer<GDismissFeedbackVars> _$gDismissFeedbackVarsSerializer =
    _$GDismissFeedbackVarsSerializer();

class _$GFeedbackRequestVarsSerializer
    implements StructuredSerializer<GFeedbackRequestVars> {
  @override
  final Iterable<Type> types = const [
    GFeedbackRequestVars,
    _$GFeedbackRequestVars
  ];
  @override
  final String wireName = 'GFeedbackRequestVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GFeedbackRequestVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GFeedbackRequestVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GFeedbackRequestVarsBuilder();

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

class _$GSendFeedbackMessageVarsSerializer
    implements StructuredSerializer<GSendFeedbackMessageVars> {
  @override
  final Iterable<Type> types = const [
    GSendFeedbackMessageVars,
    _$GSendFeedbackMessageVars
  ];
  @override
  final String wireName = 'GSendFeedbackMessageVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSendFeedbackMessageVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'decisionId',
      serializers.serialize(object.decisionId,
          specifiedType: const FullType(String)),
      'text',
      serializers.serialize(object.text, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GSendFeedbackMessageVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSendFeedbackMessageVarsBuilder();

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
        case 'text':
          result.text = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GAcceptFeedbackGuidanceVarsSerializer
    implements StructuredSerializer<GAcceptFeedbackGuidanceVars> {
  @override
  final Iterable<Type> types = const [
    GAcceptFeedbackGuidanceVars,
    _$GAcceptFeedbackGuidanceVars
  ];
  @override
  final String wireName = 'GAcceptFeedbackGuidanceVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAcceptFeedbackGuidanceVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'decisionId',
      serializers.serialize(object.decisionId,
          specifiedType: const FullType(String)),
      'guidance',
      serializers.serialize(object.guidance,
          specifiedType: const FullType(String)),
      'scope',
      serializers.serialize(object.scope,
          specifiedType: const FullType(_i2.GGuidanceScope)),
    ];
    Object? value;
    value = object.agentConfigId;
    if (value != null) {
      result
        ..add('agentConfigId')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.rating;
    if (value != null) {
      result
        ..add('rating')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    return result;
  }

  @override
  GAcceptFeedbackGuidanceVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAcceptFeedbackGuidanceVarsBuilder();

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
        case 'guidance':
          result.guidance = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'scope':
          result.scope = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GGuidanceScope))!
              as _i2.GGuidanceScope;
          break;
        case 'agentConfigId':
          result.agentConfigId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'rating':
          result.rating = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
      }
    }

    return result.build();
  }
}

class _$GDismissFeedbackVarsSerializer
    implements StructuredSerializer<GDismissFeedbackVars> {
  @override
  final Iterable<Type> types = const [
    GDismissFeedbackVars,
    _$GDismissFeedbackVars
  ];
  @override
  final String wireName = 'GDismissFeedbackVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDismissFeedbackVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'decisionId',
      serializers.serialize(object.decisionId,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.rating;
    if (value != null) {
      result
        ..add('rating')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    return result;
  }

  @override
  GDismissFeedbackVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDismissFeedbackVarsBuilder();

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
        case 'rating':
          result.rating = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
      }
    }

    return result.build();
  }
}

class _$GFeedbackRequestVars extends GFeedbackRequestVars {
  @override
  final String id;

  factory _$GFeedbackRequestVars(
          [void Function(GFeedbackRequestVarsBuilder)? updates]) =>
      (GFeedbackRequestVarsBuilder()..update(updates))._build();

  _$GFeedbackRequestVars._({required this.id}) : super._();
  @override
  GFeedbackRequestVars rebuild(
          void Function(GFeedbackRequestVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GFeedbackRequestVarsBuilder toBuilder() =>
      GFeedbackRequestVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GFeedbackRequestVars && id == other.id;
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
    return (newBuiltValueToStringHelper(r'GFeedbackRequestVars')..add('id', id))
        .toString();
  }
}

class GFeedbackRequestVarsBuilder
    implements Builder<GFeedbackRequestVars, GFeedbackRequestVarsBuilder> {
  _$GFeedbackRequestVars? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GFeedbackRequestVarsBuilder();

  GFeedbackRequestVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GFeedbackRequestVars other) {
    _$v = other as _$GFeedbackRequestVars;
  }

  @override
  void update(void Function(GFeedbackRequestVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GFeedbackRequestVars build() => _build();

  _$GFeedbackRequestVars _build() {
    final _$result = _$v ??
        _$GFeedbackRequestVars._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GFeedbackRequestVars', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GSendFeedbackMessageVars extends GSendFeedbackMessageVars {
  @override
  final String decisionId;
  @override
  final String text;

  factory _$GSendFeedbackMessageVars(
          [void Function(GSendFeedbackMessageVarsBuilder)? updates]) =>
      (GSendFeedbackMessageVarsBuilder()..update(updates))._build();

  _$GSendFeedbackMessageVars._({required this.decisionId, required this.text})
      : super._();
  @override
  GSendFeedbackMessageVars rebuild(
          void Function(GSendFeedbackMessageVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSendFeedbackMessageVarsBuilder toBuilder() =>
      GSendFeedbackMessageVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSendFeedbackMessageVars &&
        decisionId == other.decisionId &&
        text == other.text;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, decisionId.hashCode);
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSendFeedbackMessageVars')
          ..add('decisionId', decisionId)
          ..add('text', text))
        .toString();
  }
}

class GSendFeedbackMessageVarsBuilder
    implements
        Builder<GSendFeedbackMessageVars, GSendFeedbackMessageVarsBuilder> {
  _$GSendFeedbackMessageVars? _$v;

  String? _decisionId;
  String? get decisionId => _$this._decisionId;
  set decisionId(String? decisionId) => _$this._decisionId = decisionId;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  GSendFeedbackMessageVarsBuilder();

  GSendFeedbackMessageVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _decisionId = $v.decisionId;
      _text = $v.text;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSendFeedbackMessageVars other) {
    _$v = other as _$GSendFeedbackMessageVars;
  }

  @override
  void update(void Function(GSendFeedbackMessageVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSendFeedbackMessageVars build() => _build();

  _$GSendFeedbackMessageVars _build() {
    final _$result = _$v ??
        _$GSendFeedbackMessageVars._(
          decisionId: BuiltValueNullFieldError.checkNotNull(
              decisionId, r'GSendFeedbackMessageVars', 'decisionId'),
          text: BuiltValueNullFieldError.checkNotNull(
              text, r'GSendFeedbackMessageVars', 'text'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GAcceptFeedbackGuidanceVars extends GAcceptFeedbackGuidanceVars {
  @override
  final String decisionId;
  @override
  final String guidance;
  @override
  final _i2.GGuidanceScope scope;
  @override
  final String? agentConfigId;
  @override
  final int? rating;

  factory _$GAcceptFeedbackGuidanceVars(
          [void Function(GAcceptFeedbackGuidanceVarsBuilder)? updates]) =>
      (GAcceptFeedbackGuidanceVarsBuilder()..update(updates))._build();

  _$GAcceptFeedbackGuidanceVars._(
      {required this.decisionId,
      required this.guidance,
      required this.scope,
      this.agentConfigId,
      this.rating})
      : super._();
  @override
  GAcceptFeedbackGuidanceVars rebuild(
          void Function(GAcceptFeedbackGuidanceVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAcceptFeedbackGuidanceVarsBuilder toBuilder() =>
      GAcceptFeedbackGuidanceVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAcceptFeedbackGuidanceVars &&
        decisionId == other.decisionId &&
        guidance == other.guidance &&
        scope == other.scope &&
        agentConfigId == other.agentConfigId &&
        rating == other.rating;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, decisionId.hashCode);
    _$hash = $jc(_$hash, guidance.hashCode);
    _$hash = $jc(_$hash, scope.hashCode);
    _$hash = $jc(_$hash, agentConfigId.hashCode);
    _$hash = $jc(_$hash, rating.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAcceptFeedbackGuidanceVars')
          ..add('decisionId', decisionId)
          ..add('guidance', guidance)
          ..add('scope', scope)
          ..add('agentConfigId', agentConfigId)
          ..add('rating', rating))
        .toString();
  }
}

class GAcceptFeedbackGuidanceVarsBuilder
    implements
        Builder<GAcceptFeedbackGuidanceVars,
            GAcceptFeedbackGuidanceVarsBuilder> {
  _$GAcceptFeedbackGuidanceVars? _$v;

  String? _decisionId;
  String? get decisionId => _$this._decisionId;
  set decisionId(String? decisionId) => _$this._decisionId = decisionId;

  String? _guidance;
  String? get guidance => _$this._guidance;
  set guidance(String? guidance) => _$this._guidance = guidance;

  _i2.GGuidanceScope? _scope;
  _i2.GGuidanceScope? get scope => _$this._scope;
  set scope(_i2.GGuidanceScope? scope) => _$this._scope = scope;

  String? _agentConfigId;
  String? get agentConfigId => _$this._agentConfigId;
  set agentConfigId(String? agentConfigId) =>
      _$this._agentConfigId = agentConfigId;

  int? _rating;
  int? get rating => _$this._rating;
  set rating(int? rating) => _$this._rating = rating;

  GAcceptFeedbackGuidanceVarsBuilder();

  GAcceptFeedbackGuidanceVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _decisionId = $v.decisionId;
      _guidance = $v.guidance;
      _scope = $v.scope;
      _agentConfigId = $v.agentConfigId;
      _rating = $v.rating;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAcceptFeedbackGuidanceVars other) {
    _$v = other as _$GAcceptFeedbackGuidanceVars;
  }

  @override
  void update(void Function(GAcceptFeedbackGuidanceVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAcceptFeedbackGuidanceVars build() => _build();

  _$GAcceptFeedbackGuidanceVars _build() {
    final _$result = _$v ??
        _$GAcceptFeedbackGuidanceVars._(
          decisionId: BuiltValueNullFieldError.checkNotNull(
              decisionId, r'GAcceptFeedbackGuidanceVars', 'decisionId'),
          guidance: BuiltValueNullFieldError.checkNotNull(
              guidance, r'GAcceptFeedbackGuidanceVars', 'guidance'),
          scope: BuiltValueNullFieldError.checkNotNull(
              scope, r'GAcceptFeedbackGuidanceVars', 'scope'),
          agentConfigId: agentConfigId,
          rating: rating,
        );
    replace(_$result);
    return _$result;
  }
}

class _$GDismissFeedbackVars extends GDismissFeedbackVars {
  @override
  final String decisionId;
  @override
  final int? rating;

  factory _$GDismissFeedbackVars(
          [void Function(GDismissFeedbackVarsBuilder)? updates]) =>
      (GDismissFeedbackVarsBuilder()..update(updates))._build();

  _$GDismissFeedbackVars._({required this.decisionId, this.rating}) : super._();
  @override
  GDismissFeedbackVars rebuild(
          void Function(GDismissFeedbackVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDismissFeedbackVarsBuilder toBuilder() =>
      GDismissFeedbackVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDismissFeedbackVars &&
        decisionId == other.decisionId &&
        rating == other.rating;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, decisionId.hashCode);
    _$hash = $jc(_$hash, rating.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GDismissFeedbackVars')
          ..add('decisionId', decisionId)
          ..add('rating', rating))
        .toString();
  }
}

class GDismissFeedbackVarsBuilder
    implements Builder<GDismissFeedbackVars, GDismissFeedbackVarsBuilder> {
  _$GDismissFeedbackVars? _$v;

  String? _decisionId;
  String? get decisionId => _$this._decisionId;
  set decisionId(String? decisionId) => _$this._decisionId = decisionId;

  int? _rating;
  int? get rating => _$this._rating;
  set rating(int? rating) => _$this._rating = rating;

  GDismissFeedbackVarsBuilder();

  GDismissFeedbackVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _decisionId = $v.decisionId;
      _rating = $v.rating;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDismissFeedbackVars other) {
    _$v = other as _$GDismissFeedbackVars;
  }

  @override
  void update(void Function(GDismissFeedbackVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDismissFeedbackVars build() => _build();

  _$GDismissFeedbackVars _build() {
    final _$result = _$v ??
        _$GDismissFeedbackVars._(
          decisionId: BuiltValueNullFieldError.checkNotNull(
              decisionId, r'GDismissFeedbackVars', 'decisionId'),
          rating: rating,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
