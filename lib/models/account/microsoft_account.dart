import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/api/minecraft_services_api.dart';
import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/mc_access_token.dart';
import 'package:one_launcher/models/account/skin/online_skin.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/json/json_key_ignore.dart';

part 'microsoft_account.g.dart';

@immutable
@CopyWith()
@JsonSerializable()
class MicrosoftAccount extends Account {
  MicrosoftAccount({
    required String uuid,
    required String displayName,
    required String accessToken,
    required String refreshToken,
    required int notAfter,
    required this.loginType,
    this.skins = const [],
  })  : _uuid = uuid,
        _displayName = displayName,
        _minecraftAccessToken = MinecraftAccessToken(
          accessToken: accessToken,
          refreshToken: refreshToken,
          notAfter: notAfter,
        );

  factory MicrosoftAccount.fromJson(JsonMap json) =>
      _$MicrosoftAccountFromJson(json);

  @override
  String get displayName => _displayName;
  final String _displayName;

  @override
  @JsonKeyIgnore()
  OnlineSkin get skin => skins.first;

  @JsonKeyIgnore()
  final List<OnlineSkin> skins;

  @override
  String get uuid => _uuid;
  final String _uuid;

  final MinecraftAccessToken _minecraftAccessToken;

  Future<String> refreshAccessToken() async {
    await _minecraftAccessToken.refreshAccessToken(loginType);
    return _minecraftAccessToken.accessToken;
  }

  @override
  String get accessToken => _minecraftAccessToken.accessToken;

  final MicrosoftLoginType loginType;

  @override
  AccountType get type => AccountType.microsoft;

  String get refreshToken => _minecraftAccessToken.refreshToken;

  int get notAfter => _minecraftAccessToken.notAfter;

  bool get isExpired => _minecraftAccessToken.isExpired;

  Future<MicrosoftAccount> refresh() async {
    final newProfile = await requestProfile();
    return copyWith(
      displayName: newProfile.name,
      skins: newProfile.skins,
    );
  }

  Future<Profile> requestProfile() async {
    await refreshAccessToken();
    return MinecraftServicesApi(accessToken).requestProfile();
  }

  @override
  int get hashCode => uuid.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! MicrosoftAccount) return false;
    return uuid == other.uuid;
  }

  @override
  JsonMap toJson() => _$MicrosoftAccountToJson(this);
}

@JsonEnum()
enum MicrosoftLoginType {
  devicecode,
  oauth20,
}
