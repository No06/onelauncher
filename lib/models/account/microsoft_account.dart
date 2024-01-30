import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/skin.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/utils/auth/ms_auth_util.dart';

part 'microsoft_account.g.dart';

@JsonSerializable()
class MicrosoftAccount extends Account {
  MicrosoftAccount(String uuid, String displayName, String msRefreshToken)
      : _uuid = uuid,
        _displayName = displayName,
        _msRefreshToken = msRefreshToken;

  final String _uuid;
  String _displayName;
  String _msRefreshToken;

  @override
  String get uuid => _uuid;

  @override
  String get displayName => _displayName;

  @override
  @JsonKey(includeToJson: true)
  AccountType get type => AccountType.microsoft;

  String get msRefreshToken => _msRefreshToken;

  @override
  // TODO: implement skin
  Skin get skin => throw UnimplementedError();

  @override
  Future<String> accessToken() async {
    var mau = MicrosoftAuthUtil();
    _msRefreshToken = await mau.doRefreshTokens(_msRefreshToken);
    return await mau.doGetJWT();
  }

  factory MicrosoftAccount.fromJson(Map<String, dynamic> json) =>
      _$MicrosoftAccountFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MicrosoftAccountToJson(this);

  @override
  int get hashCode => uuid.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! MicrosoftAccount) return false;
    return uuid == other.uuid;
  }
}
