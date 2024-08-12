import 'package:json_annotation/json_annotation.dart';

part 'oauth_token.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class OAuthToken {
  const OAuthToken({
    required this.accessToken,
    required this.expiresIn,
    this.refreshToken,
  });

  final String accessToken;
  final String? refreshToken;
  final int expiresIn;
}
