part of 'preference.dart';

mixin _GameSettingPreferenceMixin {
  GameSetting? get gameSetting =>
      prefs.getFromJson(PreferenceKeys.gameSetting, GameSetting.fromJson);

  Future<bool> setGameSetting(GameSetting gameSetting) => prefs.setString(
        PreferenceKeys.gameSetting,
        _objectJsonEncode(gameSetting),
      );
}
