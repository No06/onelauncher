import 'dart:convert';
import 'package:one_launcher/utils/http.dart';

// 获取code
String? _getUrlCode(final String url) {
  const url =
      'https://login.live.com/oauth20_authorize.srf?client_id=00000000402b5328&response_type=code&scope=service%3A%3Auser.auth.xboxlive.com%3A%3AMBI_SSL&redirect_uri=https%3A%2F%2Flogin.live.com%2Foauth20_desktop.srf';
  final uri = Uri.parse(url);
  return uri.queryParameters['code'];
}

class MicrosoftAuthUtil {
  late String code;
  late String msAcessToken;
  late String msRefeshToken;
  late String xblToken;
  late String xstsToken;
  late String uhs;
  late String minecraftToken;

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

  Future<void> getPlayerProfile() async {
    const url = 'https://api.minecraftservices.com/minecraft/profile';
    final Map<String, String> header = {
      'Authorization': 'Bearer $minecraftToken'
    };
    final response = await httpGet(url, header: header);
    print(response);
  }
}

void main() async {
  MicrosoftAuthUtil mau = MicrosoftAuthUtil();
  mau.code = 'M.C106_SN1.2.ecb1a86e-582d-17b3-6b06-730b5225140d';
  await mau.getMSOauthToken();
  await mau.refreshMSOauthToken();
  // await mau.getXBoxLiveToken();
  // await mau.getXSTSToken();
  // final mctoken = await mau.getMinecraftToken();
  // print(mctoken);
  // mau.getPlayerProfile();
}
