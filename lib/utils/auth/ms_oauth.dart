import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'ms_oauth.g.dart';

abstract class MicrosoftOAuth {
  static const _clientId = "00000000402b5328";

  /// 使用 已保存的 refreshToekn 获取新的 Microsoft AccessToken。
  static Future<MicrosoftOAuthResponse> refreshAuthToken(
    String refreshToken,
  ) async {
    const uri = 'https://login.live.com/oauth20_token.srf';
    final data = {
      "client_id": _clientId,
      "refresh_token": refreshToken,
      "grant_type": "refresh_token",
      "redirect_uri": "https://login.live.com/oauth20_desktop.srf",
      "scope": "service::user.auth.xboxlive.com::MBI_SSL"
    };
    final response = await Dio().postUri(Uri.parse(uri), data: data);
    return MicrosoftOAuthResponse.fromJson(response.data);
  }

  /// 获取 Microsoft AccessToken 和 RefreshToken
  ///
  /// [code] 传入在Web视图中，完成 Microsoft 账号登录后的授权码
  static Future<MicrosoftOAuthResponse> getAccessToken(String code) async {
    const uri = 'https://login.live.com/oauth20_token.srf';
    final data = {
      "client_id": _clientId, // 还是Minecraft客户端id
      "code": code, // 第一步中获取的代码
      "grant_type": "authorization_code",
      "redirect_uri": "https://login.live.com/oauth20_desktop.srf",
      "scope": "service::user.auth.xboxlive.com::MBI_SSL"
    };
    final response = await Dio().postUri(Uri.parse(uri), data: data);
    return MicrosoftOAuthResponse.fromJson(response.data);
  }
}

@JsonSerializable(createToJson: false)
class MicrosoftOAuthResponse {
  const MicrosoftOAuthResponse(
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
  );

  factory MicrosoftOAuthResponse.fromJson(JsonMap json) =>
      _$MicrosoftOAuthResponseFromJson(json);

  @JsonKey(name: "access_token")
  final String accessToken;

  @JsonKey(name: "refresh_token")
  final String refreshToken;

  @JsonKey(name: "expires_in")
  final int expiresIn;
}
