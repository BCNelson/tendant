// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_assignment.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GAgentAssignmentVars> _$gAgentAssignmentVarsSerializer =
    _$GAgentAssignmentVarsSerializer();

class _$GAgentAssignmentVarsSerializer
    implements StructuredSerializer<GAgentAssignmentVars> {
  @override
  final Iterable<Type> types = const [
    GAgentAssignmentVars,
    _$GAgentAssignmentVars
  ];
  @override
  final String wireName = 'GAgentAssignmentVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAgentAssignmentVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GAgentAssignmentVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAgentAssignmentVarsBuilder();

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

class _$GAgentAssignmentVars extends GAgentAssignmentVars {
  @override
  final String id;

  factory _$GAgentAssignmentVars(
          [void Function(GAgentAssignmentVarsBuilder)? updates]) =>
      (GAgentAssignmentVarsBuilder()..update(updates))._build();

  _$GAgentAssignmentVars._({required this.id}) : super._();
  @override
  GAgentAssignmentVars rebuild(
          void Function(GAgentAssignmentVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAgentAssignmentVarsBuilder toBuilder() =>
      GAgentAssignmentVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAgentAssignmentVars && id == other.id;
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
    return (newBuiltValueToStringHelper(r'GAgentAssignmentVars')..add('id', id))
        .toString();
  }
}

class GAgentAssignmentVarsBuilder
    implements Builder<GAgentAssignmentVars, GAgentAssignmentVarsBuilder> {
  _$GAgentAssignmentVars? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GAgentAssignmentVarsBuilder();

  GAgentAssignmentVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAgentAssignmentVars other) {
    _$v = other as _$GAgentAssignmentVars;
  }

  @override
  void update(void Function(GAgentAssignmentVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAgentAssignmentVars build() => _build();

  _$GAgentAssignmentVars _build() {
    final _$result = _$v ??
        _$GAgentAssignmentVars._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GAgentAssignmentVars', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
