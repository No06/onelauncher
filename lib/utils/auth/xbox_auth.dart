import 'package:dio/dio.dart';

abstract class XboxAuth {
  /// 使用微软账号访问令牌 [msAccessToken] 获取 XboxLive Token
  ///
  /// 随后返回 Xbox Live 的 Token 和 UserHash.
  ///
  /// 如果是使用设备码登录则需在 [msAccessToken] 前加上 "d=" 字符串
  ///
  /// 返回Map，keys: "token", "uhs".
  static Future<Map<String, String>> getXboxLiveToken(
    String msAccessToken,
  ) async {
    const uri = 'https://user.auth.xboxlive.com/user/authenticate';
    final data = {
      "Properties": {
        "AuthMethod": "RPS",
        "SiteName": "user.auth.xboxlive.com",
        "RpsTicket": msAccessToken
      },
      "RelyingParty": "http://auth.xboxlive.com",
      "TokenType": "JWT"
    };

    final response = await Dio().postUri(Uri.parse(uri), data: data);
    return {
      "token": response.data['Token'],
      "uhs": response.data['DisplayClaims']['xui'][0]['uhs']
    };
  }

  /// 获取XSTS令牌
  ///
  /// 传入在 Xbox Live 身份验证中获取的 [xboxLiveToken].
  ///
  /// 返回 XSTS Token.
  static Future<String> getXSTSToken(String xboxLiveToken) async {
    const uri = 'https://xsts.auth.xboxlive.com/xsts/authorize';
    final data = {
      "Properties": {
        "SandboxId": "RETAIL",
        "UserTokens": [
          xboxLiveToken // from above
        ]
      },
      "RelyingParty": "rp://api.minecraftservices.com/",
      "TokenType": "JWT"
    };

    final response = await Dio().postUri(Uri.parse(uri), data: data);
    return response.data['Token'];
  }
}
