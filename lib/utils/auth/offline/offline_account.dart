import 'package:beacon/utils/auth/account.dart';
import 'package:beacon/utils/auth/offline/skin.dart';
import 'package:uuid/uuid.dart';

class OfflineAccount extends Account {
  final String _username;
  String? _uuid;
  Skin? _skin;

  OfflineAccount(this._username);

  @override
  Skin get skin =>
      _skin ??
      (uuid.hashCode & 1 == 1
          ? const Skin(SkinType.alex)
          : const Skin(SkinType.steve));

  @override
  String get username => _username;

  @override
  String get uuid => _uuid ?? const Uuid().v5(Uuid.NAMESPACE_OID, username);
}
