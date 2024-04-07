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

Map<String, dynamic> _$OfflineAccountToJson(OfflineAccount instance) {
  final val = <String, dynamic>{
    'type': _$AccountTypeEnumMap[instance.type]!,
    'uuid': instance.uuid,
    'displayName': instance.displayName,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('skin', instance.skin?.toJson());
  return val;
}

const _$AccountTypeEnumMap = {
  AccountType.offline: 'offline',
  AccountType.microsoft: 'microsoft',
  AccountType.custom: 'custom',
};
