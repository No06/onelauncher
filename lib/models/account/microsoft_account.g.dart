// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'microsoft_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MicrosoftAccount _$MicrosoftAccountFromJson(Map<String, dynamic> json) =>
    MicrosoftAccount(
      uuid: json['uuid'] as String,
      displayName: json['displayName'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$MicrosoftAccountToJson(MicrosoftAccount instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'displayName': instance.displayName,
      'type': _$AccountTypeEnumMap[instance.type]!,
      'refreshToken': instance.refreshToken,
    };

const _$AccountTypeEnumMap = {
  AccountType.offline: 'offline',
  AccountType.microsoft: 'microsoft',
  AccountType.custom: 'custom',
};
