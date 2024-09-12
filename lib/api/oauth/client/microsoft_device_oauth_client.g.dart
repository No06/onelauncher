// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'microsoft_device_oauth_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MicrosoftDeviceAuthorizationResponse
    _$MicrosoftDeviceAuthorizationResponseFromJson(Map<String, dynamic> json) =>
        MicrosoftDeviceAuthorizationResponse(
          json['device_code'] as String,
          json['user_code'] as String,
          json['verification_uri'] as String,
          (json['expires_in'] as num).toInt(),
          (json['interval'] as num).toInt(),
          json['message'] as String,
        );

MicrosoftDeviceOAuthException _$MicrosoftDeviceOAuthExceptionFromJson(
        Map<String, dynamic> json) =>
    MicrosoftDeviceOAuthException(
      $enumDecode(_$MicrosoftDeviceOAuthExceptionTypeEnumMap, json['error'],
          unknownValue: MicrosoftDeviceOAuthExceptionType.unknown),
    );

const _$MicrosoftDeviceOAuthExceptionTypeEnumMap = {
  MicrosoftDeviceOAuthExceptionType.authorizationPending:
      'authorization_pending',
  MicrosoftDeviceOAuthExceptionType.authorizationDeclined:
      'authorization_declined',
  MicrosoftDeviceOAuthExceptionType.badVerificationCode:
      'bad_verification_code',
  MicrosoftDeviceOAuthExceptionType.expiredToken: 'expired_token',
  MicrosoftDeviceOAuthExceptionType.unknown: 'unknown',
};
