// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_task.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GCreateTaskVars> _$gCreateTaskVarsSerializer =
    _$GCreateTaskVarsSerializer();

class _$GCreateTaskVarsSerializer
    implements StructuredSerializer<GCreateTaskVars> {
  @override
  final Iterable<Type> types = const [GCreateTaskVars, _$GCreateTaskVars];
  @override
  final String wireName = 'GCreateTaskVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GCreateTaskVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.description;
    if (value != null) {
      result
        ..add('description')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GCreateTaskVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCreateTaskVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'description':
          result.description = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GCreateTaskVars extends GCreateTaskVars {
  @override
  final String title;
  @override
  final String? description;

  factory _$GCreateTaskVars([void Function(GCreateTaskVarsBuilder)? updates]) =>
      (GCreateTaskVarsBuilder()..update(updates))._build();

  _$GCreateTaskVars._({required this.title, this.description}) : super._();
  @override
  GCreateTaskVars rebuild(void Function(GCreateTaskVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateTaskVarsBuilder toBuilder() => GCreateTaskVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateTaskVars &&
        title == other.title &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCreateTaskVars')
          ..add('title', title)
          ..add('description', description))
        .toString();
  }
}

class GCreateTaskVarsBuilder
    implements Builder<GCreateTaskVars, GCreateTaskVarsBuilder> {
  _$GCreateTaskVars? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  GCreateTaskVarsBuilder();

  GCreateTaskVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCreateTaskVars other) {
    _$v = other as _$GCreateTaskVars;
  }

  @override
  void update(void Function(GCreateTaskVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateTaskVars build() => _build();

  _$GCreateTaskVars _build() {
    final _$result = _$v ??
        _$GCreateTaskVars._(
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GCreateTaskVars', 'title'),
          description: description,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
