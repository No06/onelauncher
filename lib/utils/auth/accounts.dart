import 'package:get/get.dart';

import '/utils/auth/account.dart';

abstract class Accounts {
  static final _map = <String, Account>{}.obs;
  static Map get map => _map;

  static bool add(Account account) {
    if (_map.containsValue(account)) return true;
    _map.addAll({account.username: account});
    return false;
  }

  static bool delete(Account account) {
    if (_map.containsValue(account)) {
      _map.remove(account.username);
      return true;
    }
    return false;
  }

  static void setCustomSkin(Map user, String skin) {
    if (!user.containsKey("skin")) {
      Map<String, String> theSkin = {"skin": skin};
      user.addAll(theSkin);
    }
    if (user.containsKey("skin")) {
      user.update("skin", (value) => skin);
    }
  }

  static void setDefaultSkin(Map user) {
    if (user.containsKey("skin")) {
      user.remove("skin");
    }
  }
}

enum AccountLoginMode {
  offline,
  ms,
  custom,
}
