part of 'preference.dart';

mixin _GamePathPreferenceMixin {
  GamePathState? get gamePath =>
      prefs.getFromJson(PreferenceKeys.gamePath, GamePathState.fromJson);

  Future<bool> setGamePath(GamePathState gamePath) =>
      prefs.setToJson(PreferenceKeys.gamePath, gamePath.toJson);
}
