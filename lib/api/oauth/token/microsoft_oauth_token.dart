import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/api/oauth/token/oauth_token.dart';

part 'microsoft_oauth_token.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class MicrosoftOAuthToken extends OAuthToken {
  const MicrosoftOAuthToken(
    this.tokenType,
    this.scope,
    this.userId,
    this.foci, {
    required super.accessToken,
    super.refreshToken,
    required super.expiresIn,
  });

  /// always 'Bearer'
  final String tokenType;
  final String scope;
  final String userId;
  final String foci;

  factory MicrosoftOAuthToken.fromJson(JsonMap json) =>
      _$MicrosoftOAuthTokenFromJson(json);
}
