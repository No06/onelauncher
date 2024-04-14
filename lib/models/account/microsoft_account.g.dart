// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'microsoft_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MicrosoftAccount _$MicrosoftAccountFromJson(Map<String, dynamic> json) =>
    MicrosoftAccount(
      uuid: json['uuid'] as String,
      displayName: json['displayName'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      notAfter: json['notAfter'] as int,
    );

Map<String, dynamic> _$MicrosoftAccountToJson(MicrosoftAccount instance) =>
    <String, dynamic>{
      'type': _$AccountTypeEnumMap[instance.type]!,
      'displayName': instance.displayName,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'notAfter': instance.notAfter,
      'uuid': instance.uuid,
    };

const _$AccountTypeEnumMap = {
  AccountType.offline: 'offline',
  AccountType.microsoft: 'microsoft',
  AccountType.custom: 'custom',
};
