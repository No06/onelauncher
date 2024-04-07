import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/online_skin.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/auth/account_info_util.dart';
import 'package:one_launcher/utils/auth/ms_auth_util.dart';
import 'package:one_launcher/utils/auth/profile.dart';

part 'microsoft_account.g.dart';

@JsonSerializable()
class MicrosoftAccount extends Account {
  MicrosoftAccount({
    required String uuid,
    required String displayName,
    required String refreshToken,
    OnlineSkin? skin,
  })  : _uuid = uuid,
        _displayName = displayName,
        _refreshToken = refreshToken,
        _skin = skin;

  final String _uuid;
  String _displayName;
  String _refreshToken; // MicrosoftRefreshToken
  OnlineSkin? _skin;
  String? _accessToken; // MincraftAccessToken

  @override
  String get uuid => _uuid;

  @override
  String get displayName => _displayName;

  @override
  @JsonKey(includeToJson: true)
  AccountType get type => AccountType.microsoft;

  String get refreshToken => _refreshToken;

  /// 通过微软OAuth授权码登录返回一个 [MicrosoftAccount] 对象
  static Future<MicrosoftAccount> generateByOAuthCode(String code) async {
    final oauthResponse = await MicrosoftAuthUtil.getOAuthToken(code);
    final msAccessToken = oauthResponse.accessToken;
    final refreshToken = oauthResponse.refreshToken;
    final mcAccessToken =
        await MicrosoftAuthUtil.doGetMCAccessToken(msAccessToken);
    final profileUtil = AccountInfoUtil(mcAccessToken);
    final profile = await profileUtil.getProfile();
    final uuid = profile.id;
    final username = profile.name;
    return MicrosoftAccount(
      uuid: uuid,
      displayName: username,
      refreshToken: refreshToken,
      skin: profile.skins.first,
    );
  }

  Future<OnlineSkin> _getSkin() async => (await getProfile()).skins.first;

  Future<String> _getAccessToken() async {
    final res = await MicrosoftAuthUtil.refreshAuthToken(_refreshToken);
    return await MicrosoftAuthUtil.doGetMCAccessToken(res.accessToken);
  }

  Future<Profile> getProfile() async {
    final util = AccountInfoUtil(await getAccessToken());
    return await util.getProfile();
  }

  @override
  Future<OnlineSkin> getSkin() async => _skin ??= await _getSkin();

  /// 获取 MinecraftAccessToken
  @override
  Future<String> getAccessToken() async =>
      _accessToken ??= await _getAccessToken();

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
