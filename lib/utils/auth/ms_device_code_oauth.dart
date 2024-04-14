import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/auth/ms_oauth.dart';

part 'ms_device_code_oauth.g.dart';

typedef PollCallBack = void Function(String userCode, String verificationUrl);

// 实现参考官方文档：https://learn.microsoft.com/zh-cn/entra/identity-platform/v2-oauth2-device-code
class MicrosoftDeviceCodeOAuth {
  var _continue = true;
  void cancel() => _continue = false;

  static const deviceCodeUrl =
      'https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode';
  static const tokenUrl =
      'https://login.microsoftonline.com/consumers/oauth2/v2.0/token';
  static const clientId = "8b6fb1f0-7e3e-41d3-8171-53ff17134e00";

  /// 用于设备码登录，最终返回授权码
  ///
  /// 当开始轮询时执行 [startPolling]，返回设备码和授权链接
  ///
  /// 执行 [cancel] 时返回 null
  Future<MicrosoftOAuthResponse?> getAccessTokenByUserCode({
    required PollCallBack startPolling,
  }) async {
    // 1. 获取设备码
    final deviceCodeResponse = await getDeviceCode();
    final deviceCode = deviceCodeResponse.deviceCode;
    final userCode = deviceCodeResponse.userCode;
    final verificationUri = deviceCodeResponse.verificationUri;

    // 2. 引导用户设备授权响应
    startPolling(userCode, verificationUri);

    // 3. 轮询对用户进行身份验证
    while (true) {
      if (!_continue) return null;
      final data = await _getAccessTokenByDeviceCode(deviceCode);
      if (data.containsKey('access_token')) {
        return MicrosoftOAuthResponse.fromJson(data);
      }

      switch (data['error']) {
        case 'authorization_pending':
          await Future.delayed(const Duration(seconds: 2)); // 等待一段时间继续轮询
        case 'authorization_declined':
          throw Exception("用户拒绝了授权请求");
        case 'bad_verification_code':
          throw Exception('未识别已发送到终结点的 device_code');
        case 'expired_token':
          throw Exception('授权已超时');
        default:
          throw Exception(data['error']);
      }
    }
  }

  /// 获取设备码
  static Future<DeviceCodeResponse> getDeviceCode() async {
    const body = {
      'client_id': clientId,
      'scope': 'XboxLive.signin offline_access',
    };

    final response = await http.post(Uri.parse(deviceCodeUrl), body: body);

    if (response.statusCode != 200) {
      throw HttpException('获取设备码失败：${response.reasonPhrase}');
    }

    return DeviceCodeResponse.fromJson(jsonDecode(response.body));
  }

  /// 使用此请求轮询对用户进行身份验证，最终获取访问令牌
  static Future<JsonMap> _getAccessTokenByDeviceCode(
    String deviceCode,
  ) async {
    final response = await http.post(
      Uri.parse(tokenUrl),
      body: {
        'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        'client_id': clientId,
        'device_code': deviceCode
      },
    );

    return jsonDecode(response.body);
  }
}

@JsonSerializable(createToJson: false)
class DeviceCodeResponse {
  const DeviceCodeResponse(
    this.deviceCode,
    this.userCode,
    this.verificationUri,
    this.expiresIn,
    this.interval,
    this.message,
  );

  @JsonKey(name: "device_code")
  final String deviceCode;

  @JsonKey(name: "user_code")
  final String userCode;

  @JsonKey(name: "verification_uri")
  final String verificationUri;

  @JsonKey(name: "expires_in")
  final int expiresIn;

  final int interval;
  final String message;

  factory DeviceCodeResponse.fromJson(JsonMap json) =>
      _$DeviceCodeResponseFromJson(json);
}
