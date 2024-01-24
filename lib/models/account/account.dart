import 'package:one_launcher/models/account/account_login_info.dart';
import 'package:one_launcher/models/account/microsoft_account.dart';
import 'package:one_launcher/models/account/offline_account.dart';
import 'package:one_launcher/models/account/skin.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable(createFactory: false)
abstract class Account {
  const Account(this._type);

  String get uuid;
  String get displayName;
  Skin get skin;
  String get accessToken;

  final AccountType _type;
  AccountType get type => _type;

  Future<AccountLoginInfo> login();

  factory Account.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case "offline":
        return OfflineAccount.fromJson(json);
      case "microsoft":
        return MicrosoftAccount.fromJson(json);
      default:
        throw Exception("未知账号类型: ${json['type']}");
    }
  }

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@JsonEnum()
enum AccountType {
  offline("offline"),
  microsoft("microsoft"),
  custom("custom");

  const AccountType(this.type);
  final String type;
}
