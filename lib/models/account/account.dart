import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/account/account_login_info.dart';
import 'package:one_launcher/models/account/microsoft_account.dart';
import 'package:one_launcher/models/account/offline_account.dart';
import 'package:one_launcher/models/account/skin/skin.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/json/json_key_ignore.dart';

part 'account.g.dart';

@JsonSerializable(createFactory: false)
abstract class Account {
  const Account();

  factory Account.fromJson(JsonMap json) {
    switch (json['type']) {
      case "offline":
        return OfflineAccount.fromJson(json);
      case "microsoft":
        return MicrosoftAccount.fromJson(json);
      default:
        throw Exception("未知账号类型: ${json['type']}");
    }
  }

  String get uuid;
  String get displayName;
  String get accessToken;
  AccountType get type;
  Skin get skin;

  @JsonKeyIgnore()
  AccountLoginInfo get loginInfo => AccountLoginInfo(
        username: displayName,
        uuid: uuid,
        accessToken: accessToken,
      );

  JsonMap toJson() => _$AccountToJson(this);
}

@JsonEnum()
enum AccountType {
  offline("offline"),
  microsoft("microsoft"),
  custom("custom");

  const AccountType(this.type);
  final String type;
}
