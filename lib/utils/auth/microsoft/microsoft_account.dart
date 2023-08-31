import 'package:beacon/utils/auth/account.dart';

import '../offline/skin.dart';

class MicrosoftAccount extends Account {
  final String _username;
  final String _uuid;

  const MicrosoftAccount(this._username, this._uuid);

  @override
  String get username => _username;

  @override
  String get uuid => _uuid;

  @override
  // TODO: implement skin
  Skin get skin => throw UnimplementedError();
}
