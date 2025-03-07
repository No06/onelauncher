// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfflineAccount _$OfflineAccountFromJson(Map<String, dynamic> json) =>
    OfflineAccount(
      displayName: json['displayName'] as String,
      uuid: json['uuid'] as String,
      skin: json['skin'] == null
          ? null
          : LocalSkin.fromJson(json['skin'] as Map<String, dynamic>),
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
