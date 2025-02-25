part of 'preference.dart';

mixin _ThemePreferenceMixin {
  AppThemeState? get theme =>
      prefs.getFromJson(PreferenceKeys.theme, AppThemeState.fromJson);

  Future<bool> setTheme(AppThemeState theme) => prefs.setString(
        PreferenceKeys.theme,
        _objectJsonEncode(theme),
      );
}
