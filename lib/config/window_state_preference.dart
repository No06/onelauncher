part of 'preference.dart';

mixin _WindowStatePreferenceMixin {
  WindowState? get windowState =>
      prefs.getFromJson(PreferenceKeys.windowState, WindowState.fromJson);

  Future<bool> setWindowState(WindowState windowState) =>
      prefs.setToJson(PreferenceKeys.windowState, windowState.toJson);
}
