import 'package:dio/dio.dart';
import 'package:one_launcher/api/dio/dio.dart';
import 'package:one_launcher/api/oauth/client/oauth_client.dart';
import 'package:one_launcher/api/oauth/token/microsoft_oauth_token.dart';

/// https://learn.microsoft.com/en-us/onedrive/developer/rest-api/getting-started/msa-oauth?view=odsp-graph-online
class MicrosoftOAuthClient extends OAuthClient {
  MicrosoftOAuthClient(this.clientId);

  static const _uri = "https://login.live.com/oauth20_token.srf";
  static const redirectUri = "https://login.live.com/oauth20_desktop.srf";
  static const scope = "service::user.auth.xboxlive.com::MBI_SSL";
  final uri = Uri.parse(_uri);

  final String clientId;
  final _dio =
      createDio(BaseOptions(contentType: Headers.formUrlEncodedContentType));

  // Step: 2
  Future<MicrosoftOAuthToken> requestTokenByCode(
    String code, {
    CancelToken? cancelToken,
  }) async {
    final data = {
      "client_id": clientId,
      "code": code,
      "grant_type": "authorization_code",
      "redirect_uri": redirectUri,
      "scope": scope,
    };
    final response =
        await _dio.postUri(uri, data: data, cancelToken: cancelToken);
    return MicrosoftOAuthToken.fromJson(response.data);
  }

  // Step: 3
  Future<MicrosoftOAuthToken> requestTokenByRefreshToken(
    String refreshToken, {
    CancelToken? cancelToken,
  }) async {
    final data = {
      "client_id": clientId,
      "refresh_token": refreshToken,
      "grant_type": "refresh_token",
      "redirect_uri": redirectUri,
      "scope": scope,
    };
    final response =
        await _dio.postUri(uri, data: data, cancelToken: cancelToken);
    return MicrosoftOAuthToken.fromJson(response.data);
  }
}
