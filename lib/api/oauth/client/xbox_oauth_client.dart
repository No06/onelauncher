import 'package:dio/dio.dart';
import 'package:one_launcher/api/dio/dio.dart';
import 'package:one_launcher/api/oauth/client/oauth_client.dart';
import 'package:one_launcher/api/oauth/token/xbox_oauth_token.dart';

class XboxOAuthClient extends OAuthClient {
  static const _contentType = Headers.jsonContentType;
  final _dio = createDio(BaseOptions(contentType: _contentType));

  /// 使用微软账号访问令牌 [rpsTicket] 获取 XboxLive Token
  /// 如果是使用设备码登录则需在 [rpsTicket] 前加上 "d=" 字符串
  Future<XboxOAuthToken> requestToken(
    String rpsTicket, {
    CancelToken? cancelToken,
  }) async {
    final uri = Uri(
      scheme: "https",
      host: "user.auth.xboxlive.com",
      path: "user/authenticate",
    );
    final response = await _dio.postUri(
      uri,
      data: {
        "Properties": {
          "AuthMethod": "RPS",
          "SiteName": "user.auth.xboxlive.com",
          "RpsTicket": 'd=$rpsTicket'
        },
        "RelyingParty": "http://auth.xboxlive.com",
        "TokenType": "JWT"
      },
      cancelToken: cancelToken,
    );
    return XboxOAuthToken.fromJson(response.data);
  }

  /// 获取XSTS令牌
  Future<XboxOAuthToken> requestXstsToken(
    String userToken, {
    CancelToken? cancelToken,
  }) async {
    final uri = Uri(
      scheme: 'https',
      host: 'xsts.auth.xboxlive.com',
      path: 'xsts/authorize',
    );
    final response = await _dio.postUri(
      uri,
      data: {
        "Properties": {
          "SandboxId": "RETAIL",
          "UserTokens": [
            userToken // from above
          ]
        },
        "RelyingParty": "rp://api.minecraftservices.com/",
        "TokenType": "JWT"
      },
      cancelToken: cancelToken,
    );
    return XboxOAuthToken.fromJson(response.data);
  }
}
