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
    );

Map<String, dynamic> _$MicrosoftAccountToJson(MicrosoftAccount instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'displayName': instance.displayName,
      'msRefreshToken': instance.msRefreshToken,
    };
