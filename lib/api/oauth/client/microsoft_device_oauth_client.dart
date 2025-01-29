import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/api/dio/dio.dart';
import 'package:one_launcher/api/oauth/client/oauth_client.dart';
import 'package:one_launcher/api/oauth/token/microsoft_device_oauth_token.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/json_map.dart';

part 'microsoft_device_oauth_client.g.dart';

// 实现参考官方文档：https://learn.microsoft.com/zh-cn/entra/identity-platform/v2-oauth2-device-code
class MicrosoftDeviceOAuthClient extends OAuthClient {
  static const _url = "https://login.microsoftonline.com";
  static const _tenant = 'consumers';
  static const _scope = 'Xboxlive.offline_access XboxLive.signin';

  final _dio = createDio(
    BaseOptions(
      baseUrl: _url,
      contentType: Headers.formUrlEncodedContentType,
    ),
  );
  String _pathParse(String path) => '/$_tenant$path';

  Future<MicrosoftDeviceAuthorizationResponse> requestDeviceAuthorization({
    CancelToken? cancelToken,
  }) async {
    final path = _pathParse('/oauth2/v2.0/devicecode');
    final response = await _dio.post<JsonMap>(
      path,
      // TODO: 适配多语言
      queryParameters: {'mkt': 'zh-CN'},
      data: {'client_id': kClientId, 'scope': _scope},
      cancelToken: cancelToken,
    );
    final respData = response.data;
    if (respData == null) {
      throw Exception('MicrosoftDeviceAuthorizationResponse is null');
    }
    return MicrosoftDeviceAuthorizationResponse.fromJson(respData);
  }

  /// While the user is authenticating at the `verification_uri`, the client
  /// should be polling the `/token` endpoint for the requested token using the
  /// `device_code`.
  ///
  /// [MicrosoftDeviceOAuthException] will be throw.
  Future<MicrosoftDeviceOAuthToken> requestUserAuthentication(
    String deviceCode, {
    CancelToken? cancelToken,
  }) async {
    final path = _pathParse('/oauth2/v2.0/token');
    try {
      final response = await _dio.post<JsonMap>(
        path,
        data: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
          'client_id': kClientId,
          'device_code': deviceCode,
        },
        cancelToken: cancelToken,
      );
      final respData = response.data;
      if (respData == null) {
        throw Exception('MicrosoftDeviceOAuthToken is null');
      }
      return MicrosoftDeviceOAuthToken.fromJson(respData);
    } on DioException catch (e) {
      final data = e.response?.data as JsonMap?;
      if (data == null) rethrow;
      throw MicrosoftDeviceOAuthException.fromJson(data);
    }
  }

  Future<MicrosoftDeviceOAuthToken> requestTokenByRefreshToken(
    String refreshToken, {
    CancelToken? cancelToken,
  }) async {
    final path = _pathParse('/oauth2/v2.0/token');
    final response = await _dio.post<JsonMap>(
      path,
      data: {
        'grant_type': 'refresh_token',
        'client_id': kClientId,
        'refresh_token': refreshToken,
        'scope': _scope,
      },
      cancelToken: cancelToken,
    );
    final respData = response.data;
    if (respData == null) {
      throw Exception('MicrosoftDeviceOAuthToken is null');
    }
    return MicrosoftDeviceOAuthToken.fromJson(respData);
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

  factory MicrosoftDeviceAuthorizationResponse.fromJson(JsonMap json) =>
      _$MicrosoftDeviceAuthorizationResponseFromJson(json);

  final String deviceCode;
  final String userCode;
  final String verificationUri;

  /// seconds
  final int expiresIn;
  final int interval;
  final String message;
}

@JsonSerializable(createToJson: false)
class MicrosoftDeviceOAuthException implements Exception {
  const MicrosoftDeviceOAuthException(this.type);

  factory MicrosoftDeviceOAuthException.fromJson(JsonMap json) =>
      _$MicrosoftDeviceOAuthExceptionFromJson(json);

  @JsonKey(
    name: "error",
    unknownEnumValue: MicrosoftDeviceOAuthExceptionType.unknown,
  )
  final MicrosoftDeviceOAuthExceptionType type;
}

@JsonEnum(fieldRename: FieldRename.snake)
enum MicrosoftDeviceOAuthExceptionType {
  authorizationPending,
  authorizationDeclined,
  badVerificationCode,
  expiredToken,
  unknown,
}
