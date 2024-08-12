// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'microsoft_device_oauth_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MicrosoftDeviceOAuthToken _$MicrosoftDeviceOAuthTokenFromJson(
        Map<String, dynamic> json) =>
    MicrosoftDeviceOAuthToken(
      json['token_type'] as String,
      json['scope'] as String,
      json['id_token'] as String?,
      (json['ext_expires_in'] as num).toInt(),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresIn: (json['expires_in'] as num).toInt(),
    );
