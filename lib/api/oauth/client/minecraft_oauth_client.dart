import 'package:dio/dio.dart';
import 'package:one_launcher/api/dio/dio.dart';
import 'package:one_launcher/api/oauth/client/microsoft_device_oauth_client.dart';
import 'package:one_launcher/api/oauth/client/oauth_client.dart';
import 'package:one_launcher/api/oauth/token/microsoft_device_oauth_token.dart';
import 'package:one_launcher/api/oauth/token/oauth_token.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/api/oauth/client/microsoft_oauth_client.dart';
import 'package:one_launcher/api/oauth/client/xbox_oauth_client.dart';
import 'package:one_launcher/api/oauth/token/xbox_oauth_token.dart';
import 'package:one_launcher/models/account/microsoft_account.dart';

import '../token/minecraft_oauth_token.dart';

class MinecraftOAuthClient extends OAuthClient {
  /// need 'xsts token', not 'xbox live user token'
  Future<MinecraftOAuthToken> requestToken(
    XboxOAuthToken token, {
    CancelToken? cancelToken,
  }) async {
    const uri =
        'https://api.minecraftservices.com/authentication/login_with_xbox';
    final uhs = token.displayClaims.xui.first.uhs;
    final xstsToken = token.token;
    final data = {"identityToken": "XBL3.0 x=$uhs;$xstsToken"};
    final dio = createDio(BaseOptions(contentType: Headers.jsonContentType));
    final response =
        await dio.postUri(Uri.parse(uri), data: data, cancelToken: cancelToken);
    dio.close();
    return MinecraftOAuthToken.fromJson(response.data);
  }

  /// 使用 Microsoft AccessToken 直接获取 Minecraft AccessToken
  Future<MinecraftOAuthToken> requestTokenByMicrosoftToken(
    OAuthToken token, {
    CancelToken? cancelToken,
  }) async {
    // device code auth token should add "d="
    final accessToken = switch (token) {
      MicrosoftDeviceOAuthToken() => 'd=${token.accessToken}',
      _ => token.accessToken,
    };
    // xbox authorization
    final client = XboxOAuthClient();
    final xboxLiveResponse =
        await client.requestToken(accessToken, cancelToken: cancelToken);
    final xstsToken = await client.requestXstsToken(xboxLiveResponse.token,
        cancelToken: cancelToken);
    // minecraft authorization
    final minecraftClient = MinecraftOAuthClient();
    return minecraftClient.requestToken(xstsToken, cancelToken: cancelToken);
  }

  Future<MinecraftOAuthToken> requestTokenByRefreshToken(
    String refreshToken,
    MicrosoftLoginType loginType, {
    CancelToken? cancelToken,
  }) async {
    final token = await switch (loginType) {
      MicrosoftLoginType.oauth20 => MicrosoftOAuthClient(kMinecraftClientId)
          .requestTokenByRefreshToken(refreshToken, cancelToken: cancelToken),
      MicrosoftLoginType.devicecode => MicrosoftDeviceOAuthClient()
          .requestTokenByRefreshToken(refreshToken, cancelToken: cancelToken),
    };
    return requestTokenByMicrosoftToken(token, cancelToken: cancelToken);
  }
}
