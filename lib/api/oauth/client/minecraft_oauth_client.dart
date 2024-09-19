import 'package:dio/dio.dart';
import 'package:one_launcher/api/dio/dio.dart';
import 'package:one_launcher/api/oauth/client/oauth_client.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/api/oauth/client/microsoft_oauth_client.dart';
import 'package:one_launcher/api/oauth/client/xbox_oauth_client.dart';
import 'package:one_launcher/api/oauth/token/microsoft_oauth_token.dart';
import 'package:one_launcher/api/oauth/token/xbox_oauth_token.dart';

import '../token/minecraft_oauth_token.dart';

class MinecraftOAuthClient extends OAuthClient {
  /// need 'xsts token', not 'xbox live user token'
  Future<MinecraftOAuthToken> requestToken(
    XboxOAuthToken token,
  ) async {
    const uri =
        'https://api.minecraftservices.com/authentication/login_with_xbox';
    final uhs = token.displayClaims.xui.first.uhs;
    final xstsToken = token.token;
    final data = {"identityToken": "XBL3.0 x=$uhs;$xstsToken"};
    final dio = createDio(BaseOptions(contentType: Headers.jsonContentType));
    final response = await dio.postUri(Uri.parse(uri), data: data);
    dio.close();
    return MinecraftOAuthToken.fromJson(response.data);
  }

  /// 使用 Microsoft AccessToken 直接获取 Minecraft AccessToken
  Future<MinecraftOAuthToken> requestTokenByMicrosoftToken(
    MicrosoftOAuthToken token,
  ) async {
    // xbox authorization
    final client = XboxOAuthClient();
    final xboxLiveResponse = await client.requestToken(token.accessToken);
    final xstsToken = await client.requestXstsToken(xboxLiveResponse.token);
    // minecraft authorization
    final minecraftClient = MinecraftOAuthClient();
    return minecraftClient.requestToken(xstsToken);
  }

  Future<MinecraftOAuthToken> requestTokenByRefreshToken(
    String refreshToken,
  ) async {
    final token = await MicrosoftOAuthClient(kMinecraftClientId)
        .requestTokenByRefreshToken(refreshToken);
    return requestTokenByMicrosoftToken(token);
  }
}
