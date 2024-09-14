abstract class OAuthToken {
  const OAuthToken({
    required this.accessToken,
    required this.expiresIn,
    this.refreshToken,
  });

  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
}
