import 'package:beacon/utils/auth/offline/skin.dart';

abstract class Account {
  const Account();

  String get username;
  String get uuid;
  Skin get skin;

  @override
  String toString() => "username: $username, uuid: $uuid";
}
