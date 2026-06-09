// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_detail.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GTaskDetailVars> _$gTaskDetailVarsSerializer =
    _$GTaskDetailVarsSerializer();

class _$GTaskDetailVarsSerializer
    implements StructuredSerializer<GTaskDetailVars> {
  @override
  final Iterable<Type> types = const [GTaskDetailVars, _$GTaskDetailVars];
  @override
  final String wireName = 'GTaskDetailVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GTaskDetailVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GTaskDetailVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GTaskDetailVarsBuilder();

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

class _$GTaskDetailVars extends GTaskDetailVars {
  @override
  final String id;

  factory _$GTaskDetailVars([void Function(GTaskDetailVarsBuilder)? updates]) =>
      (GTaskDetailVarsBuilder()..update(updates))._build();

  _$GTaskDetailVars._({required this.id}) : super._();
  @override
  GTaskDetailVars rebuild(void Function(GTaskDetailVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskDetailVarsBuilder toBuilder() => GTaskDetailVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskDetailVars && id == other.id;
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
    return (newBuiltValueToStringHelper(r'GTaskDetailVars')..add('id', id))
        .toString();
  }
}

class GTaskDetailVarsBuilder
    implements Builder<GTaskDetailVars, GTaskDetailVarsBuilder> {
  _$GTaskDetailVars? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GTaskDetailVarsBuilder();

  GTaskDetailVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskDetailVars other) {
    _$v = other as _$GTaskDetailVars;
  }

  @override
  void update(void Function(GTaskDetailVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskDetailVars build() => _build();

  _$GTaskDetailVars _build() {
    final _$result = _$v ??
        _$GTaskDetailVars._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GTaskDetailVars', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
