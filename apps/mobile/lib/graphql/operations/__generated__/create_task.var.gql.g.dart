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
    value = object.priority;
    if (value != null) {
      result
        ..add('priority')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i1.GTaskPriority)));
    }
    value = object.dueAt;
    if (value != null) {
      result
        ..add('dueAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i1.GTime)));
    }
    value = object.startsAt;
    if (value != null) {
      result
        ..add('startsAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i1.GTime)));
    }
    value = object.rank;
    if (value != null) {
      result
        ..add('rank')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(double)));
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
        case 'priority':
          result.priority = serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GTaskPriority))
              as _i1.GTaskPriority?;
          break;
        case 'dueAt':
          result.dueAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i1.GTime))! as _i1.GTime);
          break;
        case 'startsAt':
          result.startsAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i1.GTime))! as _i1.GTime);
          break;
        case 'rank':
          result.rank = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double?;
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
  @override
  final _i1.GTaskPriority? priority;
  @override
  final _i1.GTime? dueAt;
  @override
  final _i1.GTime? startsAt;
  @override
  final double? rank;

  factory _$GCreateTaskVars([void Function(GCreateTaskVarsBuilder)? updates]) =>
      (GCreateTaskVarsBuilder()..update(updates))._build();

  _$GCreateTaskVars._(
      {required this.title,
      this.description,
      this.priority,
      this.dueAt,
      this.startsAt,
      this.rank})
      : super._();
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
        description == other.description &&
        priority == other.priority &&
        dueAt == other.dueAt &&
        startsAt == other.startsAt &&
        rank == other.rank;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, priority.hashCode);
    _$hash = $jc(_$hash, dueAt.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, rank.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCreateTaskVars')
          ..add('title', title)
          ..add('description', description)
          ..add('priority', priority)
          ..add('dueAt', dueAt)
          ..add('startsAt', startsAt)
          ..add('rank', rank))
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

  _i1.GTaskPriority? _priority;
  _i1.GTaskPriority? get priority => _$this._priority;
  set priority(_i1.GTaskPriority? priority) => _$this._priority = priority;

  _i1.GTimeBuilder? _dueAt;
  _i1.GTimeBuilder get dueAt => _$this._dueAt ??= _i1.GTimeBuilder();
  set dueAt(_i1.GTimeBuilder? dueAt) => _$this._dueAt = dueAt;

  _i1.GTimeBuilder? _startsAt;
  _i1.GTimeBuilder get startsAt => _$this._startsAt ??= _i1.GTimeBuilder();
  set startsAt(_i1.GTimeBuilder? startsAt) => _$this._startsAt = startsAt;

  double? _rank;
  double? get rank => _$this._rank;
  set rank(double? rank) => _$this._rank = rank;

  GCreateTaskVarsBuilder();

  GCreateTaskVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _description = $v.description;
      _priority = $v.priority;
      _dueAt = $v.dueAt?.toBuilder();
      _startsAt = $v.startsAt?.toBuilder();
      _rank = $v.rank;
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
    _$GCreateTaskVars _$result;
    try {
      _$result = _$v ??
          _$GCreateTaskVars._(
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'GCreateTaskVars', 'title'),
            description: description,
            priority: priority,
            dueAt: _dueAt?.build(),
            startsAt: _startsAt?.build(),
            rank: rank,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dueAt';
        _dueAt?.build();
        _$failedField = 'startsAt';
        _startsAt?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GCreateTaskVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
