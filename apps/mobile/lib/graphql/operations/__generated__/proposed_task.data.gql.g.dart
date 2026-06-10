// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposed_task.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GAcceptProposedTaskData> _$gAcceptProposedTaskDataSerializer =
    _$GAcceptProposedTaskDataSerializer();
Serializer<GAcceptProposedTaskData_acceptProposedTask>
    _$gAcceptProposedTaskDataAcceptProposedTaskSerializer =
    _$GAcceptProposedTaskData_acceptProposedTaskSerializer();
Serializer<GDismissProposedTaskData> _$gDismissProposedTaskDataSerializer =
    _$GDismissProposedTaskDataSerializer();
Serializer<GDismissProposedTaskData_dismissProposedTask>
    _$gDismissProposedTaskDataDismissProposedTaskSerializer =
    _$GDismissProposedTaskData_dismissProposedTaskSerializer();

class _$GAcceptProposedTaskDataSerializer
    implements StructuredSerializer<GAcceptProposedTaskData> {
  @override
  final Iterable<Type> types = const [
    GAcceptProposedTaskData,
    _$GAcceptProposedTaskData
  ];
  @override
  final String wireName = 'GAcceptProposedTaskData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GAcceptProposedTaskData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'acceptProposedTask',
      serializers.serialize(object.acceptProposedTask,
          specifiedType:
              const FullType(GAcceptProposedTaskData_acceptProposedTask)),
    ];

    return result;
  }

  @override
  GAcceptProposedTaskData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAcceptProposedTaskDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'acceptProposedTask':
          result.acceptProposedTask.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GAcceptProposedTaskData_acceptProposedTask))!
              as GAcceptProposedTaskData_acceptProposedTask);
          break;
      }
    }

    return result.build();
  }
}

class _$GAcceptProposedTaskData_acceptProposedTaskSerializer
    implements
        StructuredSerializer<GAcceptProposedTaskData_acceptProposedTask> {
  @override
  final Iterable<Type> types = const [
    GAcceptProposedTaskData_acceptProposedTask,
    _$GAcceptProposedTaskData_acceptProposedTask
  ];
  @override
  final String wireName = 'GAcceptProposedTaskData_acceptProposedTask';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GAcceptProposedTaskData_acceptProposedTask object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'state',
      serializers.serialize(object.state,
          specifiedType: const FullType(_i2.GTaskState)),
    ];

    return result;
  }

  @override
  GAcceptProposedTaskData_acceptProposedTask deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GAcceptProposedTaskData_acceptProposedTaskBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'state':
          result.state = serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTaskState))! as _i2.GTaskState;
          break;
      }
    }

    return result.build();
  }
}

class _$GDismissProposedTaskDataSerializer
    implements StructuredSerializer<GDismissProposedTaskData> {
  @override
  final Iterable<Type> types = const [
    GDismissProposedTaskData,
    _$GDismissProposedTaskData
  ];
  @override
  final String wireName = 'GDismissProposedTaskData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDismissProposedTaskData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'dismissProposedTask',
      serializers.serialize(object.dismissProposedTask,
          specifiedType:
              const FullType(GDismissProposedTaskData_dismissProposedTask)),
    ];

    return result;
  }

  @override
  GDismissProposedTaskData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDismissProposedTaskDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'dismissProposedTask':
          result.dismissProposedTask.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GDismissProposedTaskData_dismissProposedTask))!
              as GDismissProposedTaskData_dismissProposedTask);
          break;
      }
    }

    return result.build();
  }
}

class _$GDismissProposedTaskData_dismissProposedTaskSerializer
    implements
        StructuredSerializer<GDismissProposedTaskData_dismissProposedTask> {
  @override
  final Iterable<Type> types = const [
    GDismissProposedTaskData_dismissProposedTask,
    _$GDismissProposedTaskData_dismissProposedTask
  ];
  @override
  final String wireName = 'GDismissProposedTaskData_dismissProposedTask';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GDismissProposedTaskData_dismissProposedTask object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'state',
      serializers.serialize(object.state,
          specifiedType: const FullType(_i2.GTaskState)),
    ];

    return result;
  }

  @override
  GDismissProposedTaskData_dismissProposedTask deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDismissProposedTaskData_dismissProposedTaskBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'state':
          result.state = serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTaskState))! as _i2.GTaskState;
          break;
      }
    }

    return result.build();
  }
}

class _$GAcceptProposedTaskData extends GAcceptProposedTaskData {
  @override
  final String G__typename;
  @override
  final GAcceptProposedTaskData_acceptProposedTask acceptProposedTask;

  factory _$GAcceptProposedTaskData(
          [void Function(GAcceptProposedTaskDataBuilder)? updates]) =>
      (GAcceptProposedTaskDataBuilder()..update(updates))._build();

  _$GAcceptProposedTaskData._(
      {required this.G__typename, required this.acceptProposedTask})
      : super._();
  @override
  GAcceptProposedTaskData rebuild(
          void Function(GAcceptProposedTaskDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAcceptProposedTaskDataBuilder toBuilder() =>
      GAcceptProposedTaskDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAcceptProposedTaskData &&
        G__typename == other.G__typename &&
        acceptProposedTask == other.acceptProposedTask;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, acceptProposedTask.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GAcceptProposedTaskData')
          ..add('G__typename', G__typename)
          ..add('acceptProposedTask', acceptProposedTask))
        .toString();
  }
}

class GAcceptProposedTaskDataBuilder
    implements
        Builder<GAcceptProposedTaskData, GAcceptProposedTaskDataBuilder> {
  _$GAcceptProposedTaskData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GAcceptProposedTaskData_acceptProposedTaskBuilder? _acceptProposedTask;
  GAcceptProposedTaskData_acceptProposedTaskBuilder get acceptProposedTask =>
      _$this._acceptProposedTask ??=
          GAcceptProposedTaskData_acceptProposedTaskBuilder();
  set acceptProposedTask(
          GAcceptProposedTaskData_acceptProposedTaskBuilder?
              acceptProposedTask) =>
      _$this._acceptProposedTask = acceptProposedTask;

  GAcceptProposedTaskDataBuilder() {
    GAcceptProposedTaskData._initializeBuilder(this);
  }

  GAcceptProposedTaskDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _acceptProposedTask = $v.acceptProposedTask.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAcceptProposedTaskData other) {
    _$v = other as _$GAcceptProposedTaskData;
  }

  @override
  void update(void Function(GAcceptProposedTaskDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GAcceptProposedTaskData build() => _build();

  _$GAcceptProposedTaskData _build() {
    _$GAcceptProposedTaskData _$result;
    try {
      _$result = _$v ??
          _$GAcceptProposedTaskData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GAcceptProposedTaskData', 'G__typename'),
            acceptProposedTask: acceptProposedTask.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'acceptProposedTask';
        acceptProposedTask.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GAcceptProposedTaskData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GAcceptProposedTaskData_acceptProposedTask
    extends GAcceptProposedTaskData_acceptProposedTask {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GTaskState state;

  factory _$GAcceptProposedTaskData_acceptProposedTask(
          [void Function(GAcceptProposedTaskData_acceptProposedTaskBuilder)?
              updates]) =>
      (GAcceptProposedTaskData_acceptProposedTaskBuilder()..update(updates))
          ._build();

  _$GAcceptProposedTaskData_acceptProposedTask._(
      {required this.G__typename, required this.id, required this.state})
      : super._();
  @override
  GAcceptProposedTaskData_acceptProposedTask rebuild(
          void Function(GAcceptProposedTaskData_acceptProposedTaskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GAcceptProposedTaskData_acceptProposedTaskBuilder toBuilder() =>
      GAcceptProposedTaskData_acceptProposedTaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GAcceptProposedTaskData_acceptProposedTask &&
        G__typename == other.G__typename &&
        id == other.id &&
        state == other.state;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GAcceptProposedTaskData_acceptProposedTask')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('state', state))
        .toString();
  }
}

class GAcceptProposedTaskData_acceptProposedTaskBuilder
    implements
        Builder<GAcceptProposedTaskData_acceptProposedTask,
            GAcceptProposedTaskData_acceptProposedTaskBuilder> {
  _$GAcceptProposedTaskData_acceptProposedTask? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GTaskState? _state;
  _i2.GTaskState? get state => _$this._state;
  set state(_i2.GTaskState? state) => _$this._state = state;

  GAcceptProposedTaskData_acceptProposedTaskBuilder() {
    GAcceptProposedTaskData_acceptProposedTask._initializeBuilder(this);
  }

  GAcceptProposedTaskData_acceptProposedTaskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _state = $v.state;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GAcceptProposedTaskData_acceptProposedTask other) {
    _$v = other as _$GAcceptProposedTaskData_acceptProposedTask;
  }

  @override
  void update(
      void Function(GAcceptProposedTaskData_acceptProposedTaskBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GAcceptProposedTaskData_acceptProposedTask build() => _build();

  _$GAcceptProposedTaskData_acceptProposedTask _build() {
    final _$result = _$v ??
        _$GAcceptProposedTaskData_acceptProposedTask._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GAcceptProposedTaskData_acceptProposedTask', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GAcceptProposedTaskData_acceptProposedTask', 'id'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GAcceptProposedTaskData_acceptProposedTask', 'state'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GDismissProposedTaskData extends GDismissProposedTaskData {
  @override
  final String G__typename;
  @override
  final GDismissProposedTaskData_dismissProposedTask dismissProposedTask;

  factory _$GDismissProposedTaskData(
          [void Function(GDismissProposedTaskDataBuilder)? updates]) =>
      (GDismissProposedTaskDataBuilder()..update(updates))._build();

  _$GDismissProposedTaskData._(
      {required this.G__typename, required this.dismissProposedTask})
      : super._();
  @override
  GDismissProposedTaskData rebuild(
          void Function(GDismissProposedTaskDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDismissProposedTaskDataBuilder toBuilder() =>
      GDismissProposedTaskDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDismissProposedTaskData &&
        G__typename == other.G__typename &&
        dismissProposedTask == other.dismissProposedTask;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, dismissProposedTask.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GDismissProposedTaskData')
          ..add('G__typename', G__typename)
          ..add('dismissProposedTask', dismissProposedTask))
        .toString();
  }
}

class GDismissProposedTaskDataBuilder
    implements
        Builder<GDismissProposedTaskData, GDismissProposedTaskDataBuilder> {
  _$GDismissProposedTaskData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GDismissProposedTaskData_dismissProposedTaskBuilder? _dismissProposedTask;
  GDismissProposedTaskData_dismissProposedTaskBuilder get dismissProposedTask =>
      _$this._dismissProposedTask ??=
          GDismissProposedTaskData_dismissProposedTaskBuilder();
  set dismissProposedTask(
          GDismissProposedTaskData_dismissProposedTaskBuilder?
              dismissProposedTask) =>
      _$this._dismissProposedTask = dismissProposedTask;

  GDismissProposedTaskDataBuilder() {
    GDismissProposedTaskData._initializeBuilder(this);
  }

  GDismissProposedTaskDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _dismissProposedTask = $v.dismissProposedTask.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDismissProposedTaskData other) {
    _$v = other as _$GDismissProposedTaskData;
  }

  @override
  void update(void Function(GDismissProposedTaskDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDismissProposedTaskData build() => _build();

  _$GDismissProposedTaskData _build() {
    _$GDismissProposedTaskData _$result;
    try {
      _$result = _$v ??
          _$GDismissProposedTaskData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GDismissProposedTaskData', 'G__typename'),
            dismissProposedTask: dismissProposedTask.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dismissProposedTask';
        dismissProposedTask.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GDismissProposedTaskData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GDismissProposedTaskData_dismissProposedTask
    extends GDismissProposedTaskData_dismissProposedTask {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GTaskState state;

  factory _$GDismissProposedTaskData_dismissProposedTask(
          [void Function(GDismissProposedTaskData_dismissProposedTaskBuilder)?
              updates]) =>
      (GDismissProposedTaskData_dismissProposedTaskBuilder()..update(updates))
          ._build();

  _$GDismissProposedTaskData_dismissProposedTask._(
      {required this.G__typename, required this.id, required this.state})
      : super._();
  @override
  GDismissProposedTaskData_dismissProposedTask rebuild(
          void Function(GDismissProposedTaskData_dismissProposedTaskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDismissProposedTaskData_dismissProposedTaskBuilder toBuilder() =>
      GDismissProposedTaskData_dismissProposedTaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDismissProposedTaskData_dismissProposedTask &&
        G__typename == other.G__typename &&
        id == other.id &&
        state == other.state;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GDismissProposedTaskData_dismissProposedTask')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('state', state))
        .toString();
  }
}

class GDismissProposedTaskData_dismissProposedTaskBuilder
    implements
        Builder<GDismissProposedTaskData_dismissProposedTask,
            GDismissProposedTaskData_dismissProposedTaskBuilder> {
  _$GDismissProposedTaskData_dismissProposedTask? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GTaskState? _state;
  _i2.GTaskState? get state => _$this._state;
  set state(_i2.GTaskState? state) => _$this._state = state;

  GDismissProposedTaskData_dismissProposedTaskBuilder() {
    GDismissProposedTaskData_dismissProposedTask._initializeBuilder(this);
  }

  GDismissProposedTaskData_dismissProposedTaskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _state = $v.state;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDismissProposedTaskData_dismissProposedTask other) {
    _$v = other as _$GDismissProposedTaskData_dismissProposedTask;
  }

  @override
  void update(
      void Function(GDismissProposedTaskData_dismissProposedTaskBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GDismissProposedTaskData_dismissProposedTask build() => _build();

  _$GDismissProposedTaskData_dismissProposedTask _build() {
    final _$result = _$v ??
        _$GDismissProposedTaskData_dismissProposedTask._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GDismissProposedTaskData_dismissProposedTask', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GDismissProposedTaskData_dismissProposedTask', 'id'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'GDismissProposedTaskData_dismissProposedTask', 'state'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
