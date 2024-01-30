// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'microsoft_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MicrosoftAccount _$MicrosoftAccountFromJson(Map<String, dynamic> json) =>
    MicrosoftAccount(
      json['uuid'] as String,
      json['displayName'] as String,
      json['msRefreshToken'] as String,
      type: $enumDecodeNullable(_$AccountTypeEnumMap, json['type']) ??
          AccountType.microsoft,
    );

Map<String, dynamic> _$MicrosoftAccountToJson(MicrosoftAccount instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'displayName': instance.displayName,
      'msRefreshToken': instance.msRefreshToken,
      'type': _$AccountTypeEnumMap[instance.type]!,
    };

const _$AccountTypeEnumMap = {
  AccountType.offline: 'offline',
  AccountType.microsoft: 'microsoft',
  AccountType.custom: 'custom',
};
