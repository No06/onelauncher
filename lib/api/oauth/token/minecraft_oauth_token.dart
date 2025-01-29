import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/api/oauth/token/oauth_token.dart';
import 'package:one_launcher/models/json_map.dart';

part 'minecraft_oauth_token.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class MinecraftOAuthToken extends OAuthToken {
  const MinecraftOAuthToken({
    required this.username,
    required this.tokenType,
    required super.accessToken,
    required super.expiresIn, super.refreshToken,
  });

  factory MinecraftOAuthToken.fromJson(JsonMap json) =>
      _$MinecraftOAuthTokenFromJson(json);

  /// some uuid, not minecraft account uuid
  final String username;
  final String tokenType;
}
