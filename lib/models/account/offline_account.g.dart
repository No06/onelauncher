// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfflineAccount _$OfflineAccountFromJson(Map<String, dynamic> json) =>
    OfflineAccount(
      json['displayName'] as String,
      type: $enumDecodeNullable(_$AccountTypeEnumMap, json['type']) ??
          AccountType.offline,
      uuid: json['uuid'] as String?,
      skin: json['skin'] == null
          ? null
          : Skin.fromJson(json['skin'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OfflineAccountToJson(OfflineAccount instance) =>
    <String, dynamic>{
      'type': _$AccountTypeEnumMap[instance.type]!,
      'uuid': instance.uuid,
      'displayName': instance.displayName,
      'skin': instance.skin.toJson(),
    };

const _$AccountTypeEnumMap = {
  AccountType.offline: 'offline',
  AccountType.microsoft: 'microsoft',
  AccountType.custom: 'custom',
};
