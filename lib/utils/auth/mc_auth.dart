import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/auth/ms_oauth.dart';
import 'package:one_launcher/utils/auth/xbox_auth.dart';

part 'mc_auth.g.dart';

@JsonSerializable(createToJson: false)
class MinecraftAuthResponse {
  const MinecraftAuthResponse(this.accessToken, this.expiresIn);

  @JsonKey(name: "access_token")
  final String accessToken;

  @JsonKey(name: "expires_in")
  final int expiresIn;

  factory MinecraftAuthResponse.fromJson(JsonMap json) =>
      _$MinecraftAuthResponseFromJson(json);
}

abstract class MinecraftAuth {
  /// 获取 Minecraft访问令牌
  ///
  /// 使用 UserHash [uhs]，和 XSTS Token [xstsToken] 获取 MinecraftAccessToken
  static Future<MinecraftAuthResponse> _loginWithXbox({
    required String uhs,
    required String xstsToken,
  }) async {
    const url =
        'https://api.minecraftservices.com/authentication/login_with_xbox';
    const header = {"Content-Type": "application/json"};
    final data = {"identityToken": "XBL3.0 x=$uhs;$xstsToken"};
    final dio = Dio(BaseOptions(headers: header));
    final response = await dio.postUri(Uri.parse(url), data: data);
    return MinecraftAuthResponse.fromJson(response.data);
  }

  /// 使用 Microsoft AccessToken 直接获取 Minecraft AccessToken
  static Future<MinecraftAuthResponse> loginWithMsAccessToken(
    String msAccessToken,
  ) async {
    final xboxLiveResponse = await XboxAuth.getXboxLiveToken(msAccessToken);
    final xboxLiveToken = xboxLiveResponse["token"]!;
    final uhs = xboxLiveResponse["uhs"]!;
    final xstsToken = await XboxAuth.getXSTSToken(xboxLiveToken);
    return await MinecraftAuth._loginWithXbox(uhs: uhs, xstsToken: xstsToken);
  }

  /// 使用 已保存的 refreshToekn 获取新的 Microsoft AccessToken。
  static Future<MinecraftAuthResponse> loginWithRefreshToken(
    String refreshToken,
  ) async {
    final res = await MicrosoftOAuth.refreshAuthToken(refreshToken);
    return await loginWithMsAccessToken(res.accessToken);
  }
}
