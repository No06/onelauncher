import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'ms_oauth_response.g.dart';

@JsonSerializable(createToJson: false)
class MicrosoftOAuthResponse {
  const MicrosoftOAuthResponse(this.accessToken, this.refreshToken);

  @JsonKey(name: "access_token")
  final String accessToken;

  @JsonKey(name: "refresh_token")
  final String refreshToken;

  factory MicrosoftOAuthResponse.fromJson(JsonMap json) =>
      _$MicrosoftOAuthResponseFromJson(json);
}
