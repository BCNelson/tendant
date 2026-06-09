// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_subscription.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GInboxItemArrivedVars> _$gInboxItemArrivedVarsSerializer =
    _$GInboxItemArrivedVarsSerializer();

class _$GInboxItemArrivedVarsSerializer
    implements StructuredSerializer<GInboxItemArrivedVars> {
  @override
  final Iterable<Type> types = const [
    GInboxItemArrivedVars,
    _$GInboxItemArrivedVars
  ];
  @override
  final String wireName = 'GInboxItemArrivedVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInboxItemArrivedVars object,
      {FullType specifiedType = FullType.unspecified}) {
    return <Object?>[];
  }

  @override
  GInboxItemArrivedVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return GInboxItemArrivedVarsBuilder().build();
  }
}

class _$GInboxItemArrivedVars extends GInboxItemArrivedVars {
  factory _$GInboxItemArrivedVars(
          [void Function(GInboxItemArrivedVarsBuilder)? updates]) =>
      (GInboxItemArrivedVarsBuilder()..update(updates))._build();

  _$GInboxItemArrivedVars._() : super._();
  @override
  GInboxItemArrivedVars rebuild(
          void Function(GInboxItemArrivedVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInboxItemArrivedVarsBuilder toBuilder() =>
      GInboxItemArrivedVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInboxItemArrivedVars;
  }

  @override
  int get hashCode {
    return 274288232;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(r'GInboxItemArrivedVars').toString();
  }
}

class GInboxItemArrivedVarsBuilder
    implements Builder<GInboxItemArrivedVars, GInboxItemArrivedVarsBuilder> {
  _$GInboxItemArrivedVars? _$v;

  GInboxItemArrivedVarsBuilder();

  @override
  void replace(GInboxItemArrivedVars other) {
    _$v = other as _$GInboxItemArrivedVars;
  }

  @override
  void update(void Function(GInboxItemArrivedVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInboxItemArrivedVars build() => _build();

  _$GInboxItemArrivedVars _build() {
    final _$result = _$v ?? _$GInboxItemArrivedVars._();
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
