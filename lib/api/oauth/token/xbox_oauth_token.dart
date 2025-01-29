import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'xbox_oauth_token.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.pascal)
class XboxOAuthToken {

  XboxOAuthToken(
    this.issueInstant,
    this.notAfter,
    this.token,
    this.displayClaims,
  );

  factory XboxOAuthToken.fromJson(JsonMap json) =>
      _$XboxOAuthTokenFromJson(json);
  final DateTime issueInstant;
  final DateTime notAfter;
  final String token;
  final DisplayClaims displayClaims;
}

@JsonSerializable(createToJson: false)
class DisplayClaims {

  DisplayClaims({required this.xui});

  factory DisplayClaims.fromJson(JsonMap json) => _$DisplayClaimsFromJson(json);
  final List<Xui> xui;
}

@JsonSerializable(createToJson: false)
class Xui {

  Xui({required this.uhs});

  factory Xui.fromJson(JsonMap json) => _$XuiFromJson(json);
  final String uhs;
}
