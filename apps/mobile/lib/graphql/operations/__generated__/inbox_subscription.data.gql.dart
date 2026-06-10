// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:tendant/graphql/__generated__/serializers.gql.dart' as _i1;

part 'inbox_subscription.data.gql.g.dart';

abstract class GInboxEntryArrivedData
    implements Built<GInboxEntryArrivedData, GInboxEntryArrivedDataBuilder> {
  GInboxEntryArrivedData._();

  factory GInboxEntryArrivedData(
          [void Function(GInboxEntryArrivedDataBuilder b) updates]) =
      _$GInboxEntryArrivedData;

  static void _initializeBuilder(GInboxEntryArrivedDataBuilder b) =>
      b..G__typename = 'Subscription';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  GInboxEntryArrivedData_inboxEntryArrived get inboxEntryArrived;
  static Serializer<GInboxEntryArrivedData> get serializer =>
      _$gInboxEntryArrivedDataSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxEntryArrivedData.serializer,
        json,
      );
}

abstract class GInboxEntryArrivedData_inboxEntryArrived
    implements
        Built<GInboxEntryArrivedData_inboxEntryArrived,
            GInboxEntryArrivedData_inboxEntryArrivedBuilder> {
  GInboxEntryArrivedData_inboxEntryArrived._();

  factory GInboxEntryArrivedData_inboxEntryArrived(
      [void Function(GInboxEntryArrivedData_inboxEntryArrivedBuilder b)
          updates]) = _$GInboxEntryArrivedData_inboxEntryArrived;

  static void _initializeBuilder(
          GInboxEntryArrivedData_inboxEntryArrivedBuilder b) =>
      b..G__typename = 'InboxEntry';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  String get id;
  String get kind;
  double get urgency;
  GInboxEntryArrivedData_inboxEntryArrived_item get item;
  static Serializer<GInboxEntryArrivedData_inboxEntryArrived> get serializer =>
      _$gInboxEntryArrivedDataInboxEntryArrivedSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData_inboxEntryArrived.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData_inboxEntryArrived? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxEntryArrivedData_inboxEntryArrived.serializer,
        json,
      );
}

abstract class GInboxEntryArrivedData_inboxEntryArrived_item
    implements
        Built<GInboxEntryArrivedData_inboxEntryArrived_item,
            GInboxEntryArrivedData_inboxEntryArrived_itemBuilder> {
  GInboxEntryArrivedData_inboxEntryArrived_item._();

  factory GInboxEntryArrivedData_inboxEntryArrived_item(
      [void Function(GInboxEntryArrivedData_inboxEntryArrived_itemBuilder b)
          updates]) = _$GInboxEntryArrivedData_inboxEntryArrived_item;

  static void _initializeBuilder(
          GInboxEntryArrivedData_inboxEntryArrived_itemBuilder b) =>
      b..G__typename = 'InboxItem';

  @BuiltValueField(wireName: '__typename')
  String get G__typename;
  static Serializer<GInboxEntryArrivedData_inboxEntryArrived_item>
      get serializer => _$gInboxEntryArrivedDataInboxEntryArrivedItemSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInboxEntryArrivedData_inboxEntryArrived_item? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInboxEntryArrivedData_inboxEntryArrived_item.serializer,
        json,
      );
}
