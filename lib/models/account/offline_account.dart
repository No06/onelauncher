import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/skin.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'offline_account.g.dart';

@JsonSerializable(explicitToJson: true)
class OfflineAccount extends Account {
  OfflineAccount(
    String displayName, {
    AccountType type = AccountType.offline,
    String? uuid,
    Skin? skin,
  })  : _displayName = displayName,
        super(type) {
    _uuid = uuid ?? const Uuid().v4();
    _skin = skin ??
        Skin(type: _uuid.hashCode & 1 == 1 ? SkinType.alex : SkinType.steve);
  }

  String _displayName;
  late String _uuid;
  late Skin _skin;

  set displayName(String newVal) {
    displayName = newVal;
    _uuid = const Uuid().v4();
  }

  factory OfflineAccount.fromJson(Map<String, dynamic> json) =>
      _$OfflineAccountFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OfflineAccountToJson(this);

  @override
  AccountType get type => AccountType.offline;

  @override
  String get uuid => _uuid;

  @override
  String get displayName => _displayName;

  @override
  Skin get skin => _skin;
}
