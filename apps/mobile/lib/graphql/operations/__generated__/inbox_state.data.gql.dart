// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/schema.schema.gql.dart' as _i2;
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'inbox_state.data.gql.g.dart';

abstract class GMarkInboxReadData
    implements Built<GMarkInboxReadData, GMarkInboxReadDataBuilder> {
  GMarkInboxReadData._();

  factory GMarkInboxReadData(
          [void Function(GMarkInboxReadDataBuilder b) updates]) =
      _$GMarkInboxReadData;

  static void _initializeBuilder(GMarkInboxReadDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GMarkInboxReadData_markInboxRead get markInboxRead;
  static Serializer<GMarkInboxReadData> get serializer =>
      _$gMarkInboxReadDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GMarkInboxReadData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GMarkInboxReadData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GMarkInboxReadData.serializer,
        json,
      );
}

abstract class GMarkInboxReadData_markInboxRead
    implements
        Built<GMarkInboxReadData_markInboxRead,
            GMarkInboxReadData_markInboxReadBuilder> {
  GMarkInboxReadData_markInboxRead._();

  factory GMarkInboxReadData_markInboxRead(
          [void Function(GMarkInboxReadData_markInboxReadBuilder b) updates]) =
      _$GMarkInboxReadData_markInboxRead;

  static void _initializeBuilder(GMarkInboxReadData_markInboxReadBuilder b) =>
      b..G__typename = 'InboxMessageState';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GTime? get seenAt;
  _i2.GTime? get readAt;
  _i2.GTime? get dismissedAt;
  static Serializer<GMarkInboxReadData_markInboxRead> get serializer =>
      _$gMarkInboxReadDataMarkInboxReadSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GMarkInboxReadData_markInboxRead.serializer,
        this,
      ) as Map<String, dynamic>);

  static GMarkInboxReadData_markInboxRead? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GMarkInboxReadData_markInboxRead.serializer,
        json,
      );
}

abstract class GDismissInboxMessageData
    implements
        Built<GDismissInboxMessageData, GDismissInboxMessageDataBuilder> {
  GDismissInboxMessageData._();

  factory GDismissInboxMessageData(
          [void Function(GDismissInboxMessageDataBuilder b) updates]) =
      _$GDismissInboxMessageData;

  static void _initializeBuilder(GDismissInboxMessageDataBuilder b) =>
      b..G__typename = 'Mutation';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GDismissInboxMessageData_dismissInboxMessage get dismissInboxMessage;
  static Serializer<GDismissInboxMessageData> get serializer =>
      _$gDismissInboxMessageDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDismissInboxMessageData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDismissInboxMessageData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDismissInboxMessageData.serializer,
        json,
      );
}

abstract class GDismissInboxMessageData_dismissInboxMessage
    implements
        Built<GDismissInboxMessageData_dismissInboxMessage,
            GDismissInboxMessageData_dismissInboxMessageBuilder> {
  GDismissInboxMessageData_dismissInboxMessage._();

  factory GDismissInboxMessageData_dismissInboxMessage(
      [void Function(GDismissInboxMessageData_dismissInboxMessageBuilder b)
          updates]) = _$GDismissInboxMessageData_dismissInboxMessage;

  static void _initializeBuilder(
          GDismissInboxMessageData_dismissInboxMessageBuilder b) =>
      b..G__typename = 'InboxMessageState';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  _i2.GTime? get seenAt;
  _i2.GTime? get readAt;
  _i2.GTime? get dismissedAt;
  static Serializer<GDismissInboxMessageData_dismissInboxMessage>
      get serializer => _$gDismissInboxMessageDataDismissInboxMessageSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDismissInboxMessageData_dismissInboxMessage.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDismissInboxMessageData_dismissInboxMessage? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDismissInboxMessageData_dismissInboxMessage.serializer,
        json,
      );
}
