// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ms_device_code_oauth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceCodeResponse _$DeviceCodeResponseFromJson(Map<String, dynamic> json) =>
    DeviceCodeResponse(
      json['device_code'] as String,
      json['user_code'] as String,
      json['verification_uri'] as String,
      json['expires_in'] as int,
      json['interval'] as int,
      json['message'] as String,
    );
