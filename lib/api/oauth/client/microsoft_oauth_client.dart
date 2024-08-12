import 'package:dio/dio.dart';
import 'package:one_launcher/api/oauth/token/microsoft_oauth_token.dart';

class MicrosoftOAuthClient {
  MicrosoftOAuthClient(this.clientId);

  static const _uri = "https://login.live.com/oauth20_token.srf";
  static const _redirectUri = "https://login.live.com/oauth20_desktop.srf";
  static const _scope = "service::user.auth.xboxlive.com::MBI_SSL";

  final String clientId;
  final dio = Dio(BaseOptions(
    baseUrl: 'https://login.live.com',
    contentType: Headers.formUrlEncodedContentType,
  ));

  late final uri = Uri.parse(_uri);

  Future<MicrosoftOAuthToken> requestTokenByRefreshToken(
    String refreshToken,
  ) async {
    final data = {
      "client_id": clientId,
      "refresh_token": refreshToken,
      "grant_type": "refresh_token",
      "redirect_uri": _redirectUri,
      "scope": _scope
    };
    final response = await dio.postUri(uri, data: data);
    return MicrosoftOAuthToken.fromJson(response.data);
  }

  Future<MicrosoftOAuthToken> requestTokenByCode(String code) async {
    final data = {
      "client_id": clientId,
      "code": code,
      "grant_type": "authorization_code",
      "redirect_uri": _redirectUri,
      "scope": _scope
    };
    final response = await dio.postUri(uri, data: data);
    return MicrosoftOAuthToken.fromJson(response.data);
  }
}
