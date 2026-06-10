// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_subscription.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GInboxEntryArrivedVars> _$gInboxEntryArrivedVarsSerializer =
    _$GInboxEntryArrivedVarsSerializer();

class _$GInboxEntryArrivedVarsSerializer
    implements StructuredSerializer<GInboxEntryArrivedVars> {
  @override
  final Iterable<Type> types = const [
    GInboxEntryArrivedVars,
    _$GInboxEntryArrivedVars
  ];
  @override
  final String wireName = 'GInboxEntryArrivedVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxEntryArrivedVars object,
      {FullType specifiedType = FullType.unspecified}) {
    return <Object?>[];
  }

  @override
  GInboxEntryArrivedVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return GInboxEntryArrivedVarsBuilder().build();
  }
}

class _$GInboxEntryArrivedVars extends GInboxEntryArrivedVars {
  factory _$GInboxEntryArrivedVars(
          [void Function(GInboxEntryArrivedVarsBuilder)? updates]) =>
      (GInboxEntryArrivedVarsBuilder()..update(updates))._build();

  _$GInboxEntryArrivedVars._() : super._();
  @override
  GInboxEntryArrivedVars rebuild(
          void Function(GInboxEntryArrivedVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxEntryArrivedVarsBuilder toBuilder() =>
      GInboxEntryArrivedVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxEntryArrivedVars;
  }

  @override
  int get hashCode {
    return 234691524;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(r'GInboxEntryArrivedVars').toString();
  }
}

class GInboxEntryArrivedVarsBuilder
    implements Builder<GInboxEntryArrivedVars, GInboxEntryArrivedVarsBuilder> {
  _$GInboxEntryArrivedVars? _$v;

  GInboxEntryArrivedVarsBuilder();

  @override
  void replace(GInboxEntryArrivedVars other) {
    _$v = other as _$GInboxEntryArrivedVars;
  }

  @override
  void update(void Function(GInboxEntryArrivedVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxEntryArrivedVars build() => _build();

  _$GInboxEntryArrivedVars _build() {
    final _$result = _$v ?? _$GInboxEntryArrivedVars._();
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
