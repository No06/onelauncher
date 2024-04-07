import 'dart:convert';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/auth/ms_oauth_response.dart';
import 'package:one_launcher/utils/http.dart';

abstract final class MicrosoftAuthUtil {
  /// 从url中提取code
  ///
  /// 像这样的url: https://login.live.com/oauth20_desktop.srf?code=codegoeshere&lc=1033
  ///
  static String getCode(String url) =>
      url.split("/").last.split('?').last.split("&").first.split('=').last;

  /// 获取 Microsoft Oauth 的 AccessToken 和 RefreshToken, 用于 XBox Live 身份验证
  ///
  /// 传入在Web视图中，完成 Microsoft账号 登录后的参数中的 [code],
  ///
  static Future<MicrosoftOAuthResponse> getOAuthToken(String code) async {
    const url = 'https://login.live.com/oauth20_token.srf';
    final params = {
      "client_id": "00000000402b5328", // 还是Minecraft客户端id
      "code": code, // 第一步中获取的代码
      "grant_type": "authorization_code",
      "redirect_uri": "https://login.live.com/oauth20_desktop.srf",
      "scope": "service::user.auth.xboxlive.com::MBI_SSL"
    };
    final response = await httpPost(url, params: params);
    return MicrosoftOAuthResponse.fromJson(response);
  }

  /// 使用 已保存的 refreshToekn 获取新的 Microsoft Oauth 的 token 。
  ///
  static Future<MicrosoftOAuthResponse> refreshAuthToken(
    String refreshToken,
  ) async {
    const url = 'https://login.live.com/oauth20_token.srf';
    final params = {
      "client_id": "00000000402b5328",
      "refresh_token": refreshToken,
      "grant_type": "refresh_token",
      "redirect_uri": "https://login.live.com/oauth20_desktop.srf",
      "scope": "service::user.auth.xboxlive.com::MBI_SSL"
    };
    final response = await httpPost(url, params: params);
    return MicrosoftOAuthResponse.fromJson(response);
  }

  /// 通过 Xbox Live 获取用于 XSTS 身份验证的 Token
  ///
  /// 传入在 Microsoft Oauth 获取的 AccessToken [msAcessToken],
  /// 随后返回 Xbox Live 的 Token 和 UserHash.
  ///
  /// 返回Map，keys: "token", "uhs".
  ///
  static Future<Map<String, String>> _getXBoxLiveToken(
      String accessToken) async {
    const url = 'https://user.auth.xboxlive.com/user/authenticate';
    const header = {"Content-Type": "application/json"};
    final params = {
      "Properties": {
        "AuthMethod": "RPS",
        "SiteName": "user.auth.xboxlive.com",
        "RpsTicket": accessToken // 第二步中获取的访问令牌
      },
      "RelyingParty": "http://auth.xboxlive.com",
      "TokenType": "JWT"
    };
    final response =
        await httpPost(url, params: jsonEncode(params), header: header);
    return {
      "token": response['Token'],
      "uhs": response['DisplayClaims']['xui'][0]['uhs']
    };
  }

  /// 获取XSTS令牌
  ///
  /// 传入在 Xbox Live 身份验证中获取的 [xblToken].
  /// 返回用于获取 Minecraft 登录令牌的 Token.
  ///
  static Future<String> _getXSTSToken(String xboxLiveToken) async {
    const url = 'https://xsts.auth.xboxlive.com/xsts/authorize';
    const header = {"Content-Type": "application/json"};
    final JsonMap params = {
      "Properties": {
        "SandboxId": "RETAIL",
        "UserTokens": [
          xboxLiveToken // from above
        ]
      },
      "RelyingParty": "rp://api.minecraftservices.com/",
      "TokenType": "JWT"
    };
    final response =
        await httpPost(url, params: jsonEncode(params), header: header);
    return response['Token'];
  }

  /// 获取 Minecraft访问令牌
  static Future<String> _getMCAccessToken({
    required String uhs,
    required String xstsToken,
  }) async {
    const url =
        'https://api.minecraftservices.com/authentication/login_with_xbox';
    const header = {"Content-Type": "application/json"};
    final params = {"identityToken": "XBL3.0 x=$uhs;$xstsToken"};
    final response =
        await httpPost(url, params: jsonEncode(params), header: header);
    return response['access_token'];
  }

  static Future<String> doGetMCAccessToken(
    String msAccessToken,
  ) async {
    final xboxLiveResponse = await _getXBoxLiveToken(msAccessToken);
    final xboxLiveToken = xboxLiveResponse["token"]!;
    final uhs = xboxLiveResponse["uhs"]!;
    final xstsToken = await _getXSTSToken(xboxLiveToken);
    return await _getMCAccessToken(uhs: uhs, xstsToken: xstsToken);
  }
}
