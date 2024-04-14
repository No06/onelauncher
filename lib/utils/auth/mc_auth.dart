import 'dart:convert';

import 'package:one_launcher/utils/auth/ms_oauth.dart';
import 'package:one_launcher/utils/auth/xbox_auth.dart';
import 'package:one_launcher/utils/http.dart';

class MinecraftAuth {
  /// 获取 Minecraft访问令牌
  ///
  /// 使用 UserHash [uhs]，和 XSTS Token [xstsToken] 获取 MinecraftAccessToken
  static Future<String> getAccessToken({
    required String uhs,
    required String xstsToken,
  }) async {
    const url =
        'https://api.minecraftservices.com/authentication/login_with_xbox';
    const header = {"Content-Type": "application/json"};
    final params = {"identityToken": "XBL3.0 x=$uhs;$xstsToken"};
    final response =
        await httpPost(url, body: jsonEncode(params), header: header);
    return response['access_token'];
  }

  /// 使用 Microsoft AccessToken 直接获取 Minecraft AccessToken
  static Future<String> getAccessTokenByMsAccessToken(
    String msAccessToken,
  ) async {
    final xboxLiveResponse = await XboxAuth.getXboxLiveToken(msAccessToken);
    final xboxLiveToken = xboxLiveResponse["token"]!;
    final uhs = xboxLiveResponse["uhs"]!;
    final xstsToken = await XboxAuth.getXSTSToken(xboxLiveToken);
    return await MinecraftAuth.getAccessToken(uhs: uhs, xstsToken: xstsToken);
  }

  /// 使用 已保存的 refreshToekn 获取新的 Microsoft AccessToken。
  static Future<String> getAccessTokenByRefreshToken(
    String refreshToken,
  ) async {
    final res = await MicrosoftOAuth.refreshAuthToken(refreshToken);
    return await getAccessTokenByMsAccessToken(res.accessToken);
  }

  /// 通过在Web视图中，完成 Microsoft 账号登录后的授权码 [code] 直接获取 Minecraft AccessToken
  static Future<MicrosoftOAuthResponse?> getAccessTokenByCode(
    String code,
  ) async =>
      await MicrosoftOAuth.getAccessToken(code);
}
