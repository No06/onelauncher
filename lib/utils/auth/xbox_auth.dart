import 'dart:convert';

import 'package:one_launcher/utils/http.dart';

abstract class XboxAuth {
  static const xboxLiveAuthUrl =
      'https://user.auth.xboxlive.com/user/authenticate';
  static const xstsAuthUrl = 'https://xsts.auth.xboxlive.com/xsts/authorize';
  static const _header = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  /// 使用微软账号访问令牌 [msAccessToken] 获取 XboxLive Token
  ///
  /// 随后返回 Xbox Live 的 Token 和 UserHash.
  ///
  /// 返回Map，keys: "token", "uhs".
  static Future<Map<String, String>> getXboxLiveToken(
      String msAccessToken) async {
    final body = {
      "Properties": {
        "AuthMethod": "RPS",
        "SiteName": "user.auth.xboxlive.com",
        "RpsTicket": msAccessToken
      },
      "RelyingParty": "http://auth.xboxlive.com",
      "TokenType": "JWT"
    };
    final response = await httpPost(xboxLiveAuthUrl,
        body: jsonEncode(body), header: _header);
    return {
      "token": response['Token'],
      "uhs": response['DisplayClaims']['xui'][0]['uhs']
    };
  }

  /// 获取XSTS令牌
  ///
  /// 传入在 Xbox Live 身份验证中获取的 [xboxLiveToken].
  ///
  /// 返回 XSTS Token.
  static Future<String> getXSTSToken(String xboxLiveToken) async {
    final params = {
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
        await httpPost(xstsAuthUrl, body: jsonEncode(params), header: _header);
    return response['Token'];
  }
}
