// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GInboxFeedVars> _$gInboxFeedVarsSerializer =
    _$GInboxFeedVarsSerializer();

class _$GInboxFeedVarsSerializer
    implements StructuredSerializer<GInboxFeedVars> {
  @override
  final Iterable<Type> types = const [GInboxFeedVars, _$GInboxFeedVars];
  @override
  final String wireName = 'GInboxFeedVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GInboxFeedVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.first;
    if (value != null) {
      result
        ..add('first')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.after;
    if (value != null) {
      result
        ..add('after')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GInboxFeedVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxFeedVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'first':
          result.first = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'after':
          result.after = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GInboxFeedVars extends GInboxFeedVars {
  @override
  final int? first;
  @override
  final String? after;

  factory _$GInboxFeedVars([void Function(GInboxFeedVarsBuilder)? updates]) =>
      (GInboxFeedVarsBuilder()..update(updates))._build();

  _$GInboxFeedVars._({this.first, this.after}) : super._();
  @override
  GInboxFeedVars rebuild(void Function(GInboxFeedVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxFeedVarsBuilder toBuilder() => GInboxFeedVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxFeedVars &&
        first == other.first &&
        after == other.after;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, first.hashCode);
    _$hash = $jc(_$hash, after.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GInboxFeedVars')
          ..add('first', first)
          ..add('after', after))
        .toString();
  }
}

class GInboxFeedVarsBuilder
    implements Builder<GInboxFeedVars, GInboxFeedVarsBuilder> {
  _$GInboxFeedVars? _$v;

  int? _first;
  int? get first => _$this._first;
  set first(int? first) => _$this._first = first;

  String? _after;
  String? get after => _$this._after;
  set after(String? after) => _$this._after = after;

  GInboxFeedVarsBuilder();

  GInboxFeedVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _first = $v.first;
      _after = $v.after;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxFeedVars other) {
    _$v = other as _$GInboxFeedVars;
  }

  @override
  void update(void Function(GInboxFeedVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxFeedVars build() => _build();

  _$GInboxFeedVars _build() {
    final _$result = _$v ??
        _$GInboxFeedVars._(
          first: first,
          after: after,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
