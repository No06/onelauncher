// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfflineAccount _$OfflineAccountFromJson(Map<String, dynamic> json) =>
    OfflineAccount(
      json['displayName'] as String,
      uuid: json['uuid'] as String?,
      skin: json['skin'] == null
          ? null
          : Skin.fromJson(json['skin'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OfflineAccountToJson(OfflineAccount instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'displayName': instance.displayName,
      'skin': instance.skin.toJson(),
    };
