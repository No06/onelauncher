import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'xbox_oauth_token.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.pascal)
class XboxOAuthToken {
  final DateTime issueInstant;
  final DateTime notAfter;
  final String token;
  final DisplayClaims displayClaims;

  XboxOAuthToken(
    this.issueInstant,
    this.notAfter,
    this.token,
    this.displayClaims,
  );

  factory XboxOAuthToken.fromJson(JsonMap json) =>
      _$XboxOAuthTokenFromJson(json);
}

@JsonSerializable(createToJson: false)
class DisplayClaims {
  final List<Xui> xui;

  DisplayClaims({required this.xui});

  factory DisplayClaims.fromJson(JsonMap json) => _$DisplayClaimsFromJson(json);
}

@JsonSerializable(createToJson: false)
class Xui {
  final String uhs;

  Xui({required this.uhs});

  factory Xui.fromJson(JsonMap json) => _$XuiFromJson(json);
}
