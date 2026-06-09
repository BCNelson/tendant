// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GTasksVars> _$gTasksVarsSerializer = _$GTasksVarsSerializer();

class _$GTasksVarsSerializer implements StructuredSerializer<GTasksVars> {
  @override
  final Iterable<Type> types = const [GTasksVars, _$GTasksVars];
  @override
  final String wireName = 'GTasksVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GTasksVars object,
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
    value = object.state;
    if (value != null) {
      result
        ..add('state')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i1.GTaskState)));
    }
    return result;
  }

  @override
  GTasksVars deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTasksVarsBuilder();

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
        case 'state':
          result.state = serializers.deserialize(value,
              specifiedType: const FullType(_i1.GTaskState)) as _i1.GTaskState?;
          break;
      }
    }

    return result.build();
  }
}

class _$GTasksVars extends GTasksVars {
  @override
  final int? first;
  @override
  final String? after;
  @override
  final _i1.GTaskState? state;

  factory _$GTasksVars([void Function(GTasksVarsBuilder)? updates]) =>
      (GTasksVarsBuilder()..update(updates))._build();

  _$GTasksVars._({this.first, this.after, this.state}) : super._();
  @override
  GTasksVars rebuild(void Function(GTasksVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTasksVarsBuilder toBuilder() => GTasksVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTasksVars &&
        first == other.first &&
        after == other.after &&
        state == other.state;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, first.hashCode);
    _$hash = $jc(_$hash, after.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTasksVars')
          ..add('first', first)
          ..add('after', after)
          ..add('state', state))
        .toString();
  }
}

class GTasksVarsBuilder implements Builder<GTasksVars, GTasksVarsBuilder> {
  _$GTasksVars? _$v;

  int? _first;
  int? get first => _$this._first;
  set first(int? first) => _$this._first = first;

  String? _after;
  String? get after => _$this._after;
  set after(String? after) => _$this._after = after;

  _i1.GTaskState? _state;
  _i1.GTaskState? get state => _$this._state;
  set state(_i1.GTaskState? state) => _$this._state = state;

  GTasksVarsBuilder();

  GTasksVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _first = $v.first;
      _after = $v.after;
      _state = $v.state;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTasksVars other) {
    _$v = other as _$GTasksVars;
  }

  @override
  void update(void Function(GTasksVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTasksVars build() => _build();

  _$GTasksVars _build() {
    final _$result = _$v ??
        _$GTasksVars._(
          first: first,
          after: after,
          state: state,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
