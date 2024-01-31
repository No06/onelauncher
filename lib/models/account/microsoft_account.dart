import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/online_skin.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/auth/account_info_util.dart';
import 'package:one_launcher/utils/auth/ms_auth_util.dart';

part 'microsoft_account.g.dart';

@JsonSerializable()
class MicrosoftAccount extends Account {
  MicrosoftAccount(String uuid, String displayName, String msRefreshToken,
      {OnlineSkin? skin})
      : _uuid = uuid,
        _displayName = displayName,
        _msRefreshToken = msRefreshToken,
        _skin = skin;

  final String _uuid;
  String _displayName;
  String _msRefreshToken;
  OnlineSkin? _skin;
  String? _jwtToken;

  @override
  String get uuid => _uuid;

  @override
  String get displayName => _displayName;

  @override
  @JsonKey(includeToJson: true)
  AccountType get type => AccountType.microsoft;

  String get msRefreshToken => _msRefreshToken;

  Future<OnlineSkin> getSkin() async {
    return _skin ?? await _refreshSkin();
  }

  Future<OnlineSkin> _refreshSkin() async {
    var aiu = AccountInfoUtil(await accessToken());
    var p = await aiu.getProfile();
    _skin = p.skins.first;
    return p.skins.first;
  }

  @override
  Future<String> accessToken() async {
    return _jwtToken ?? await _refreshAccessToken();
  }

  Future<String> _refreshAccessToken() async {
    var mau = MicrosoftAuthUtil();
    _msRefreshToken = await mau.doRefreshTokens(_msRefreshToken);
    var result = await mau.doGetJWT();
    _jwtToken = result;
    return result;
  }

  Future<void> refreshProfile() async {
    var aiu = AccountInfoUtil(await accessToken());
    await aiu.getProfile();
  }

  factory MicrosoftAccount.fromJson(JsonMap json) =>
      _$MicrosoftAccountFromJson(json);

  @override
  JsonMap toJson() => _$MicrosoftAccountToJson(this);

  @override
  int get hashCode => uuid.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! MicrosoftAccount) return false;
    return uuid == other.uuid;
  }
}
