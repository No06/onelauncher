import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/api/oauth/token/oauth_token.dart';
import 'package:one_launcher/models/json_map.dart';

part 'microsoft_oauth_token.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class MicrosoftOAuthToken extends OAuthToken {
  const MicrosoftOAuthToken(
    this.tokenType,
    this.scope,
    this.userId,
    this.foci, {
    required super.accessToken,
    required super.expiresIn, super.refreshToken,
  });

  factory MicrosoftOAuthToken.fromJson(JsonMap json) =>
      _$MicrosoftOAuthTokenFromJson(json);

  /// always 'Bearer'
  final String tokenType;
  final String scope;
  final String userId;
  final String foci;
}
