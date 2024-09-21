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
      notAfter: (json['notAfter'] as num).toInt(),
      loginType: $enumDecode(_$MicrosoftLoginTypeEnumMap, json['loginType']),
    );

Map<String, dynamic> _$MicrosoftAccountToJson(MicrosoftAccount instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'uuid': instance.uuid,
      'loginType': _$MicrosoftLoginTypeEnumMap[instance.loginType]!,
      'type': _$AccountTypeEnumMap[instance.type]!,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'notAfter': instance.notAfter,
    };

const _$MicrosoftLoginTypeEnumMap = {
  MicrosoftLoginType.devicecode: 'devicecode',
  MicrosoftLoginType.oauth20: 'oauth20',
};

const _$AccountTypeEnumMap = {
  AccountType.offline: 'offline',
  AccountType.microsoft: 'microsoft',
  AccountType.custom: 'custom',
};
