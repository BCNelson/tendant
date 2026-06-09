// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GInboxVars> _$gInboxVarsSerializer = _$GInboxVarsSerializer();

class _$GInboxVarsSerializer implements StructuredSerializer<GInboxVars> {
  @override
  final Iterable<Type> types = const [GInboxVars, _$GInboxVars];
  @override
  final String wireName = 'GInboxVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GInboxVars object,
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
  GInboxVars deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GInboxVarsBuilder();

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

class _$GInboxVars extends GInboxVars {
  @override
  final int? first;
  @override
  final String? after;

  factory _$GInboxVars([void Function(GInboxVarsBuilder)? updates]) =>
      (GInboxVarsBuilder()..update(updates))._build();

  _$GInboxVars._({this.first, this.after}) : super._();
  @override
  GInboxVars rebuild(void Function(GInboxVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxVarsBuilder toBuilder() => GInboxVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxVars && first == other.first && after == other.after;
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
    return (newBuiltValueToStringHelper(r'GInboxVars')
          ..add('first', first)
          ..add('after', after))
        .toString();
  }
}

class GInboxVarsBuilder implements Builder<GInboxVars, GInboxVarsBuilder> {
  _$GInboxVars? _$v;

  int? _first;
  int? get first => _$this._first;
  set first(int? first) => _$this._first = first;

  String? _after;
  String? get after => _$this._after;
  set after(String? after) => _$this._after = after;

  GInboxVarsBuilder();

  GInboxVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _first = $v.first;
      _after = $v.after;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInboxVars other) {
    _$v = other as _$GInboxVars;
  }

  @override
  void update(void Function(GInboxVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxVars build() => _build();

  _$GInboxVars _build() {
    final _$result = _$v ??
        _$GInboxVars._(
          first: first,
          after: after,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
