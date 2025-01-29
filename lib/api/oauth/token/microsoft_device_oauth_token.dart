import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/api/oauth/token/oauth_token.dart';
import 'package:one_launcher/models/json_map.dart';

part 'microsoft_device_oauth_token.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class MicrosoftDeviceOAuthToken extends OAuthToken {
  const MicrosoftDeviceOAuthToken(
    this.tokenType,
    this.scope,
    this.idToken,
    this.extExpiresIn, {
    required super.accessToken,
    required super.refreshToken,
    required super.expiresIn,
  });

  factory MicrosoftDeviceOAuthToken.fromJson(JsonMap json) =>
      _$MicrosoftDeviceOAuthTokenFromJson(json);

  /// always 'Bearer'
  final String tokenType;
  final String scope;
  final String? idToken;
  final int extExpiresIn;
}
