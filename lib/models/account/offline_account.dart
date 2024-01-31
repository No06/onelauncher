import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/local_skin.dart';
import 'package:one_launcher/models/account/skin.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:uuid/uuid.dart';

part 'offline_account.g.dart';

@JsonSerializable(explicitToJson: true)
class OfflineAccount extends Account {
  OfflineAccount(
    String displayName, {
    String? uuid,
    LocalSkin? skin,
  }) : _displayName = displayName {
    _uuid = uuid ?? uuidFromName;
    _skin = skin;
  }

  final String _displayName;
  late final String _uuid;
  LocalSkin? _skin;

  set displayName(String newVal) {
    displayName = newVal;
    _uuid = const Uuid().v4();
  }

  factory OfflineAccount.fromJson(JsonMap json) =>
      _$OfflineAccountFromJson(json);

  @override
  JsonMap toJson() => _$OfflineAccountToJson(this);

  @JsonKey(includeToJson: true)
  @override
  AccountType get type => AccountType.offline;

  @override
  String get uuid => _uuid;

  @override
  String get displayName => _displayName;

  Skin? get skin => _skin;

  @override
  Future<Skin> getSkin() async {
    return _skin ??
        LocalSkin(
            type: _uuid.hashCode & 1 == 1 ? SkinType.alex : SkinType.steve);
  }

  @override
  Future<String> accessToken() async => "0";

  String get uuidFromName =>
      const Uuid().v5(Uuid.NAMESPACE_NIL, getUuidFromName(displayName));

  static String getUuidFromName(String name) =>
      const Uuid().v5(Uuid.NAMESPACE_NIL, name);

  @override
  int get hashCode => displayName.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! OfflineAccount) return false;
    return displayName == other.displayName;
  }
}
