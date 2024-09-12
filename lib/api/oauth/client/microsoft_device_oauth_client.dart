import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/api/oauth/token/microsoft_device_oauth_token.dart';

part 'microsoft_device_oauth_client.g.dart';

// 实现参考官方文档：https://learn.microsoft.com/zh-cn/entra/identity-platform/v2-oauth2-device-code
class MicrosoftDeviceOAuthClient {
  static const url = "https://login.microsoftonline.com";
  static const tenant = 'consumers';

  final dio = Dio(BaseOptions(
      baseUrl: url, contentType: Headers.formUrlEncodedContentType));

  String pathParse(String path) => '/$tenant$path';

  Future<MicrosoftDeviceAuthorizationResponse>
      requestDeviceAuthorization() async {
    final path = pathParse('/oauth2/v2.0/devicecode');
    final response = await dio.post(path, queryParameters: {
      // TODO: 适配多语言
      'mkt': 'zh-CN',
    }, data: {
      'client_id': kClientId,
      'scope': 'XboxLive.signin offline_access',
    });
    return MicrosoftDeviceAuthorizationResponse.fromJson(response.data);
  }

  /// While the user is authenticating at the `verification_uri`, the client
  /// should be polling the `/token` endpoint for the requested token using the
  /// `device_code`.
  ///
  /// [MicrosoftDeviceOAuthException] will be throw.
  Future<MicrosoftDeviceOAuthToken> requestUserAuthentication(
    String deviceCode,
  ) async {
    final path = pathParse('/oauth2/v2.0/token');
    try {
      final response = await dio.post(path, data: {
        'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        'client_id': kClientId,
        'device_code': deviceCode
      });
      return MicrosoftDeviceOAuthToken.fromJson(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      final error = data['error'];
      if (error == null) rethrow;
      throw MicrosoftDeviceOAuthException.fromJson(data);
    }
  }
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class MicrosoftDeviceAuthorizationResponse {
  const MicrosoftDeviceAuthorizationResponse(
    this.deviceCode,
    this.userCode,
    this.verificationUri,
    this.expiresIn,
    this.interval,
    this.message,
  );

  final String deviceCode;
  final String userCode;
  final String verificationUri;

  /// default 15mins
  final int expiresIn;
  final int interval;
  final String message;

  factory MicrosoftDeviceAuthorizationResponse.fromJson(JsonMap json) =>
      _$MicrosoftDeviceAuthorizationResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class MicrosoftDeviceOAuthException implements Exception {
  const MicrosoftDeviceOAuthException(this.type);

  @JsonKey(
      name: "error",
      unknownEnumValue: MicrosoftDeviceOAuthExceptionType.unknown)
  final MicrosoftDeviceOAuthExceptionType type;

  factory MicrosoftDeviceOAuthException.fromJson(JsonMap json) =>
      _$MicrosoftDeviceOAuthExceptionFromJson(json);
}

@JsonEnum(fieldRename: FieldRename.snake)
enum MicrosoftDeviceOAuthExceptionType {
  authorizationPending,
  authorizationDeclined,
  badVerificationCode,
  expiredToken,
  unknown,
}
