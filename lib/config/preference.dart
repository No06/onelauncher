import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/models/window_state.dart';
import 'package:one_launcher/provider/account_provider.dart';
import 'package:one_launcher/provider/game_path_provider.dart';
import 'package:one_launcher/provider/game_setting_provider.dart';
import 'package:one_launcher/provider/theme_provider.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_preference.dart';
part 'game_setting_preference.dart';
part 'game_path_preference.dart';
part 'account_preference.dart';
part 'window_state_preference.dart';

abstract class _Preference
    with
        _ThemePreferenceMixin,
        _GameSettingPreferenceMixin,
        _GamePathPreferenceMixin,
        _AccountPreferenceMixin,
        _WindowStatePreferenceMixin {
  static void _onSet(bool result, PreferenceKeys key) => debugPrintInfo(
        result.toString(),
        title: "Preference Update: ${key.name}",
      );

  Future<bool> setBool(PreferenceKeys key, bool value) =>
      _sharedPrefs.setBool(key.name, value)
        ..then((value) => _onSet(value, key));

  Future<bool> setDouble(PreferenceKeys key, double value) =>
      _sharedPrefs.setDouble(key.name, value)
        ..then((value) => _onSet(value, key));

  Future<bool> setInt(PreferenceKeys key, int value) =>
      _sharedPrefs.setInt(key.name, value)..then((value) => _onSet(value, key));

  Future<bool> setString(PreferenceKeys key, String value) =>
      _sharedPrefs.setString(key.name, value)
        ..then((value) => _onSet(value, key));

  Future<bool> setStringList(PreferenceKeys key, List<String> value) =>
      _sharedPrefs.setStringList(key.name, value)
        ..then((value) => _onSet(value, key));

  Future<bool> setToJson(PreferenceKeys key, JsonMap Function() toJson) =>
      setString(key, jsonEncode(toJson()));

  Object? get(PreferenceKeys key) => _sharedPrefs.get(key.name);

  bool? getBool(PreferenceKeys key) => _sharedPrefs.getBool(key.name);

  double? getDouble(PreferenceKeys key) => _sharedPrefs.getDouble(key.name);

  int? getInt(PreferenceKeys key) => _sharedPrefs.getInt(key.name);

  Set<String>? getKeys() => _sharedPrefs.getKeys();

  String? getString(PreferenceKeys key) => _sharedPrefs.getString(key.name);

  List<String>? getStringList(PreferenceKeys key) =>
      _sharedPrefs.getStringList(key.name);

  T? getFromJson<T>(PreferenceKeys key, T Function(JsonMap) fromJson) {
    final data = _sharedPrefs.get(key.name) as String?;
    if (data == null) return null;
    return fromJson(jsonDecode(data) as JsonMap);
  }
}

class Preference extends _Preference {
  factory Preference() => prefs;
  Preference._();

  static Preference? _instance;
  static Preference? get instance {
    assert(_instance != null, "Should invoke after initialization");
    return _instance;
  }

  static Future<void> init(String prefix) async {
    SharedPreferences.setPrefix(prefix);
    _sharedPrefs = await SharedPreferences.getInstance();
    _prefs = Preference._();
  }
}

enum PreferenceKeys {
  theme,
  gameSetting,
  gamePath,
  account,
  windowState,
  filterState,
}

late final SharedPreferences _sharedPrefs;
@protected
Preference? _prefs;

/// should invoke after [Preference.init]
Preference get prefs {
  assert(_prefs != null, "Should invoke after initialization");
  return _prefs!;
}

/// private method to encode object to json string
// ignore: avoid_dynamic_calls
String _objectJsonEncode(dynamic object) => jsonEncode(object.toJson());
