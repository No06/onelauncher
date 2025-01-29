// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'microsoft_oauth_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MicrosoftOAuthToken _$MicrosoftOAuthTokenFromJson(Map<String, dynamic> json) =>
    MicrosoftOAuthToken(
      json['token_type'] as String,
      json['scope'] as String,
      json['user_id'] as String,
      json['foci'] as String,
      accessToken: json['access_token'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      refreshToken: json['refresh_token'] as String?,
    );
