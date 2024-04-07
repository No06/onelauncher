import 'package:one_launcher/models/account/account_login_info.dart';
import 'package:one_launcher/models/account/microsoft_account.dart';
import 'package:one_launcher/models/account/offline_account.dart';
import 'package:one_launcher/models/account/skin.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'account.g.dart';

@JsonSerializable(createFactory: false)
abstract class Account {
  const Account();

  String get uuid;
  String get displayName;

  Future<Skin> getSkin();
  Future<String> getAccessToken();

  AccountType get type;

  Future<AccountLoginInfo> login() async => AccountLoginInfo(
      username: displayName, uuid: uuid, accessToken: await getAccessToken());

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
