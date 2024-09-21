import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/mc_access_token.dart';
import 'package:one_launcher/models/account/skin/online_skin.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/api/minecraft_services_api.dart';

part 'microsoft_account.g.dart';

@JsonSerializable()
class MicrosoftAccount extends Account {
  MicrosoftAccount({
    required String uuid,
    required String displayName,
    required String accessToken,
    required String refreshToken,
    required int notAfter,
    required this.loginType,
    OnlineSkin? skin,
  })  : _uuid = uuid,
        _displayName = displayName,
        _minecraftAccessToken = MinecraftAccessToken(
          accessToken: accessToken,
          refreshToken: refreshToken,
          notAfter: notAfter,
        ),
        _skin = skin;

  @override
  String get displayName => _displayName;
  String _displayName;

  @override
  Future<OnlineSkin> getSkin() async => _skin ??= await _getSkin();
  OnlineSkin? _skin;

  @override
  String get uuid => _uuid;
  final String _uuid;

  final MinecraftAccessToken _minecraftAccessToken;
  @override
  Future<String> getAccessToken() async {
    if (!_minecraftAccessToken.isExpired) {
      await _minecraftAccessToken.refreshAccessToken(loginType);
    }
    return _minecraftAccessToken.accessToken;
  }

  final MicrosoftLoginType loginType;

  @override
  @JsonKey(includeToJson: true)
  AccountType get type => AccountType.microsoft;

  String get accessToken => _minecraftAccessToken.accessToken;

  String get refreshToken => _minecraftAccessToken.refreshToken;

  int get notAfter => _minecraftAccessToken.notAfter;

  Future<void> updateProfile() async {
    final newProfile = await requestProfile();
    _displayName = newProfile.name;
    _skin = newProfile.skins.first;
  }

  Future<Profile> requestProfile() async =>
      MinecraftServicesApi(await getAccessToken()).requestProfile();

  Future<OnlineSkin> _getSkin() async => (await requestProfile()).skins.first;

  @override
  int get hashCode => uuid.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! MicrosoftAccount) return false;
    return uuid == other.uuid;
  }

  @override
  JsonMap toJson() => _$MicrosoftAccountToJson(this);

  factory MicrosoftAccount.fromJson(JsonMap json) =>
      _$MicrosoftAccountFromJson(json);
}

@JsonEnum()
enum MicrosoftLoginType {
  devicecode,
  oauth20,
}
