import 'package:dio/dio.dart';
import 'package:one_launcher/api/oauth/token/xbox_oauth_token.dart';

class XboxOAuthClient {
  static const _contentType = Headers.jsonContentType;

  /// 使用微软账号访问令牌 [rpsTicket] 获取 XboxLive Token
  /// 如果是使用设备码登录则需在 [rpsTicket] 前加上 "d=" 字符串
  Future<XboxOAuthToken> requestToken(String rpsTicket) async {
    const path = '/user/authenticate';
    final dio = Dio(BaseOptions(
      baseUrl: "https://user.auth.xboxlive.com",
      contentType: _contentType,
    ));
    final response = await dio.post(path, data: {
      "Properties": {
        "AuthMethod": "RPS",
        "SiteName": "user.auth.xboxlive.com",
        "RpsTicket": rpsTicket
      },
      "RelyingParty": "http://auth.xboxlive.com",
      "TokenType": "JWT"
    });
    return XboxOAuthToken.fromJson(response.data);
  }

  /// 获取XSTS令牌
  Future<XboxOAuthToken> requestXstsToken(String userToken) async {
    const path = '/xsts/authorize';
    final dio = Dio(BaseOptions(
      baseUrl: "https://xsts.auth.xboxlive.com",
      contentType: _contentType,
    ));
    final response = await dio.post(path, data: {
      "Properties": {
        "SandboxId": "RETAIL",
        "UserTokens": [
          userToken // from above
        ]
      },
      "RelyingParty": "rp://api.minecraftservices.com/",
      "TokenType": "JWT"
    });
    return XboxOAuthToken.fromJson(response.data);
  }
}
