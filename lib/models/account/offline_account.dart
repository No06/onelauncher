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
        _uuid = uuid ?? const Uuid().v5(Uuid.NAMESPACE_OID, displayName),
        _skin = skin ??
            Skin(
              type: const Uuid().v5(Uuid.NAMESPACE_OID, displayName).hashCode &
                          1 ==
                      1
                  ? SkinType.alex
                  : SkinType.steve,
            ),
        super(type);

  String _displayName;
  String _uuid;
  Skin _skin;

  set uuid(String newVal) => _uuid = uuid;
  set displayName(String newVal) => displayName = newVal;

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
