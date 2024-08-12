// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minecraft_oauth_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MinecraftOAuthToken _$MinecraftOAuthTokenFromJson(Map<String, dynamic> json) =>
    MinecraftOAuthToken(
      username: json['username'] as String,
      tokenType: json['token_type'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresIn: (json['expires_in'] as num).toInt(),
    );
