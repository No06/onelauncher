import 'package:beacon/models/microsoft_account.dart';
import 'package:beacon/models/offline_account.dart';
import 'package:beacon/models/skin.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable(createFactory: false)
abstract class Account {
  const Account(this._type);

  String get uuid;
  String get displayName;
  Skin get skin;

  final AccountType _type;
  AccountType get type => _type;

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

  @override
  int get hashCode {
    return uuid.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Account) return false;
    if (other.type != _type) return false;
    return uuid == other.uuid;
  }
}

@JsonEnum()
enum AccountType {
  offline("offline"),
  microsoft("microsoft"),
  custom("custom");

  const AccountType(this.type);
  final String type;
}
