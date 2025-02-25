part of 'preference.dart';

mixin _AccountPreferenceMixin {
  AccountState? get account =>
      prefs.getFromJson(PreferenceKeys.account, AccountState.fromJson);

  Future<bool> setAccount(AccountState account) =>
      prefs.setToJson(PreferenceKeys.account, account.toJson);
}
