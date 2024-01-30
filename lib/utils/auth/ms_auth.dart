import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:one_launcher/utils/http.dart';

class MicrosoftAuthUtil {
  final Dio dio = Dio();

  String code = "";
  String msAcessToken = "";
  String msRefeshToken = "";
  String xblToken = "";
  String xstsToken = "";
  String uhs = "";
  String minecraftToken = "";

  /// 从url中提取code
  ///
  /// 像这样的url: https://login.live.com/oauth20_desktop.srf?code=codegoeshere&lc=1033
  ///
  String getCodeFromUrl(String url) {
    String res =
        url.split("/").last.split('?').last.split("&").first.split('=').last;
    code = res;
    return res;
  }

  /// 获取 Microsoft Oauth 的 AccessToken, 用于 XBox Live 身份验证
  ///
  /// 传入在Web视图中，完成 Microsoft账号 登录后的参数中的 [code],
  /// 返回 Microsoft账号 的 AccessToken .
  ///
  Future<void> getMSOauthToken() async {
    const url = 'https://login.live.com/oauth20_token.srf';
    final Map<String, String> params = {
      "client_id": "00000000402b5328", // 还是Minecraft客户端id
      "code": code, // 第一步中获取的代码
      "grant_type": "authorization_code",
      "redirect_uri": "https://login.live.com/oauth20_desktop.srf",
      "scope": "service::user.auth.xboxlive.com::MBI_SSL"
    };
    final response = await httpPost(url, params: params);
    msAcessToken = response['access_token'];
    msRefeshToken = response['refresh_token'];
  }

  /// 使用 已保存的 refreshToekn 获取新的 Microsoft Oauth 的 token 。
  ///
  Future<void> refreshMSOauthToken() async {
    const url = 'https://login.live.com/oauth20_token.srf';
    final Map<String, String> params = {
      "client_id": "00000000402b5328",
      "refresh_token": msRefeshToken,
      "grant_type": "refresh_token",
      "redirect_uri": "https://login.live.com/oauth20_desktop.srf",
      "scope": "service::user.auth.xboxlive.com::MBI_SSL"
    };
    final response = await httpPost(url, params: params);
    msAcessToken = response['access_token'];
    msRefeshToken = response['refresh_token'];
  }

  /// 通过 Xbox Live 获取用于 XSTS 身份验证的 Token
  ///
  /// 传入在 Microsoft Oauth 获取的 AccessToken [msAcessToken],
  /// 随后返回 Xbox Live 的 Token .
  ///
  Future<void> getXBoxLiveToken() async {
    const url = 'https://user.auth.xboxlive.com/user/authenticate';
    const Map<String, String> header = {"Content-Type": "application/json"};
    final params = {
      "Properties": {
        "AuthMethod": "RPS",
        "SiteName": "user.auth.xboxlive.com",
        "RpsTicket": msAcessToken // 第二步中获取的访问令牌
      },
      "RelyingParty": "http://auth.xboxlive.com",
      "TokenType": "JWT"
    };
    final response =
        await httpPost(url, params: jsonEncode(params), header: header);
    xblToken = response['Token'];
    uhs = response['DisplayClaims']['xui'][0]['uhs'];
  }

  /// 获取XSTS令牌
  ///
  /// 传入在 Xbox Live 身份验证中获取的 [xblToken].
  /// 返回用于获取 Minecraft 登录令牌的 Token.
  ///
  Future<void> getXSTSToken() async {
    const url = 'https://xsts.auth.xboxlive.com/xsts/authorize';
    const Map<String, String> header = {"Content-Type": "application/json"};
    final Map<String, dynamic> params = {
      "Properties": {
        "SandboxId": "RETAIL",
        "UserTokens": [
          xblToken // from above
        ]
      },
      "RelyingParty": "rp://api.minecraftservices.com/",
      "TokenType": "JWT"
    };
    final response =
        await httpPost(url, params: jsonEncode(params), header: header);
    xstsToken = response['Token'];
  }

  /// 获取 Minecraft访问令牌
  Future<String> getMinecraftToken() async {
    const url =
        'https://api.minecraftservices.com/authentication/login_with_xbox';
    const Map<String, String> header = {"Content-Type": "application/json"};
    final Map<String, String> params = {
      "identityToken": "XBL3.0 x=$uhs;$xstsToken"
    };
    final response =
        await httpPost(url, params: jsonEncode(params), header: header);
    minecraftToken = response['access_token'];
    return minecraftToken;
  }

  Future<String> doGetMSToken(String url) async {
    getCodeFromUrl(url);
    await getMSOauthToken();
    return msRefeshToken;
  }

  Future<String> doRefreshTokens(String refreshToken) async {
    msRefeshToken = refreshToken;
    await refreshMSOauthToken();
    return msRefeshToken;
  }

  Future<String> doGetJWT() async {
    await getXBoxLiveToken();
    await getXSTSToken();
    await getMinecraftToken();
    return minecraftToken;
  }
}
