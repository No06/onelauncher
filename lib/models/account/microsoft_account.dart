import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/mc_access_token.dart';
import 'package:one_launcher/models/account/skin/online_skin.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/auth/account_info_util.dart';
import 'package:one_launcher/utils/auth/mc_auth.dart';
import 'package:one_launcher/utils/auth/ms_oauth.dart';
import 'package:one_launcher/utils/auth/profile.dart';

part 'microsoft_account.g.dart';

@JsonSerializable()
class MicrosoftAccount extends Account {
  MicrosoftAccount({
    required String uuid,
    required String displayName,
    required String accessToken,
    required String refreshToken,
    required int notAfter,
    OnlineSkin? skin,
  })  : _uuid = uuid,
        _displayName = displayName,
        _minecraftAccessToken = MinecraftAccessToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            notAfter: notAfter),
        _skin = skin;

  String _displayName;
  OnlineSkin? _skin;
  final String _uuid;
  final MinecraftAccessToken _minecraftAccessToken;

  @override
  bool operator ==(Object other) {
    if (other is! MicrosoftAccount) return false;
    return uuid == other.uuid;
  }

  @override
  @JsonKey(includeToJson: true)
  AccountType get type => AccountType.microsoft;

  @override
  String get displayName => _displayName;

  @override
  Future<String> getAccessToken() async {
    if (_minecraftAccessToken.isExpired) {
      await _minecraftAccessToken.refreshAccessToken();
    }
    return _minecraftAccessToken.accessToken;
  }

  String get accessToken => _minecraftAccessToken.accessToken;

  String get refreshToken => _minecraftAccessToken.refreshToken;

  int get notAfter => _minecraftAccessToken.notAfter;

  @override
  Future<OnlineSkin> getSkin() async => _skin ??= await _getSkin();

  @override
  int get hashCode => uuid.hashCode;

  @override
  String get uuid => _uuid;

  /// 通过微软OAuth授权码登录返回一个 [MicrosoftAccount] 对象
  static Future<MicrosoftAccount?> generateByOAuthCode(
    String code,
  ) async {
    final response = await MicrosoftOAuth.getAccessToken(code);
    return await generateByMsToken(
      msAccessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }

  /// 使用 Microsoft AccessToken 与 RefreshToken 生成一个 [MicrosoftAccount] 对象
  static Future<MicrosoftAccount> generateByMsToken({
    required String msAccessToken,
    required String refreshToken,
  }) async {
    final response = await MinecraftAuth.loginWithMsAccessToken(msAccessToken);
    final profileUtil = AccountInfoUtil(response.accessToken);
    final profile = await profileUtil.getProfile();
    final uuid = profile.id;
    final username = profile.name;
    return MicrosoftAccount(
      uuid: uuid,
      displayName: username,
      accessToken: response.accessToken,
      refreshToken: refreshToken,
      notAfter: MinecraftAccessToken.validityToExpiredTime(response.expiresIn),
      skin: profile.skins.first,
    );
  }

  Future<void> updateProfile() async {
    final newProfile = await getProfile();
    _displayName = newProfile.name;
    _skin = newProfile.skins.first;
  }

  Future<Profile> getProfile() async =>
      AccountInfoUtil(await getAccessToken()).getProfile();

  Future<OnlineSkin> _getSkin() async => (await getProfile()).skins.first;

  factory MicrosoftAccount.fromJson(JsonMap json) =>
      _$MicrosoftAccountFromJson(json);

  @override
  JsonMap toJson() => _$MicrosoftAccountToJson(this);
}
