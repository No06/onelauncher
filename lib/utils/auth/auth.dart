import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:one_launcher/utils/http.dart';

// 获取code
String? _getUrlCode(final String url) {
  const url =
      'https://login.live.com/oauth20_authorize.srf?client_id=00000000402b5328&response_type=code&scope=service%3A%3Auser.auth.xboxlive.com%3A%3AMBI_SSL&redirect_uri=https%3A%2F%2Flogin.live.com%2Foauth20_desktop.srf';
  final uri = Uri.parse(url);
  return uri.queryParameters['code'];
}

/// 获取 Microsoft Oauth 的 AccessToken, 用于 XBox Live 身份验证
///
/// 传入在Web视图中，完成 Microsoft账号 登录后的参数中的 [code],
/// 返回 Microsoft账号 的 AccessToken .
///
Future<String> getMSOauthToken(String code) async {
  const url = 'https://login.live.com/oauth20_token.srf';
  final Map<String, String> params = {
    "client_id": "00000000402b5328", // 还是Minecraft客户端id
    "code": code, // 第一步中获取的代码
    "grant_type": "authorization_code",
    "redirect_uri": "https://login.live.com/oauth20_desktop.srf",
    "scope": "service::user.auth.xboxlive.com::MBI_SSL"
  };
  final response = await httpPost(url, params);
  // print(response);
  return response['access_token'];
}

/// 通过 Xbox Live 获取用于 XSTS 身份验证的 Token
///
/// 传入在 Microsoft Oauth 获取的 AccessToken [msAcessToken],
/// 随后返回 Xbox Live 的 Token .
///
Future<String> getXBoxLiveToken(String msAcessToken) async {
  const url = 'https://user.auth.xboxlive.com/user/authenticate';
  final Map<String, dynamic> params = {
    "Properties": {
      "AuthMethod": "RPS",
      "SiteName": "user.auth.xboxlive.com",
      "RpsTicket": "d=$msAcessToken" // 第二步中获取的访问令牌
    },
    "RelyingParty": "<nowiki>http://auth.xboxlive.com</nowiki>",
    "TokenType": "JWT"
  };
  final response = await httpPost(url, params);
  print(response);
  final xblToken = response['token'];
  final uhs = response['DisplayClaims']['xui'][0]['uhs'];
  return xblToken;
}

/// 获取XSTS令牌
///
/// 传入在 Xbox Live 身份验证中获取的 [xblToken].
/// 返回用于获取 Minecraft 登录令牌的 Token.
///
Future<String> getXSTSToken(String xblToken) async {
  const url = 'https://xsts.auth.xboxlive.com/xsts/authorize';
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
  final response = await httpPost(url, params);
  return response['Token'];
}

Future<String> getMinecraftToken(String uhs, String xstsToken) async {
  const url =
      'https://api.minecraftservices.com/authentication/login_with_xbox';
  final Map<String, dynamic> params = {
    "identityToken": "XBL3.0 x=$uhs;$xstsToken"
  };
  final response = await httpPost(url, params);
  return response['access_token'];
}

void main() async {
  const myCode = 'M.C106_BAY.2.2f7bad7b-4c92-f5bb-adb4-a1f3cae7a87e';
  final msAcessToken = await getMSOauthToken(myCode);
  print(msAcessToken);
  // final xblToken = await getXBoxLiveToken(msAcessToken);
}
