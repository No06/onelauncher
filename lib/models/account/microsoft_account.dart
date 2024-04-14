import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/online_skin.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/auth/account_info_util.dart';
import 'package:one_launcher/utils/auth/mc_auth.dart';
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

  factory MicrosoftAccount.fromJson(JsonMap json) =>
      _$MicrosoftAccountFromJson(json);

  String? _accessToken; // MincraftAccessToken
  String _displayName;
  String _refreshToken; // MicrosoftRefreshToken
  OnlineSkin? _skin;
  final String _uuid;

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

  /// 获取 MinecraftAccessToken
  @override
  Future<String> getAccessToken() async =>
      _accessToken ??= await _getAccessToken();

  @override
  Future<OnlineSkin> getSkin() async => _skin ??= await _getSkin();

  @override
  int get hashCode => uuid.hashCode;

  @override
  JsonMap toJson() => _$MicrosoftAccountToJson(this);

  @override
  String get uuid => _uuid;

  String get refreshToken => _refreshToken;

  /// 通过微软OAuth授权码登录返回一个 [MicrosoftAccount] 对象
  static Future<MicrosoftAccount?> generateByOAuthCode(
    String code,
  ) async {
    final response = await MinecraftAuth.getAccessTokenByCode(code);
    if (response == null) return null;
    return await generateByToken(response.accessToken, response.refreshToken);
  }

  /// 使用 Microsoft AccessToken 与 RefreshToken 生成一个 [MicrosoftAccount] 对象
  static Future<MicrosoftAccount> generateByToken(
    String msAccessToken,
    String refreshToken,
  ) async {
    final mcAccessToken =
        await MinecraftAuth.getAccessTokenByMsAccessToken(msAccessToken);
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

  Future<Profile> getProfile() async {
    final util = AccountInfoUtil(await getAccessToken());
    return await util.getProfile();
  }

  Future<OnlineSkin> _getSkin() async => (await getProfile()).skins.first;

  Future<String> _getAccessToken() async =>
      await MinecraftAuth.getAccessTokenByRefreshToken(refreshToken);
}
