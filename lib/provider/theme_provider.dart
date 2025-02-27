import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/config/preference.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';
import 'package:one_launcher/utils/json_converter/color_json_converter.dart';
import 'package:one_launcher/utils/json_converter/theme_mode_json_converter.dart';

part 'theme_provider.g.dart';

@CopyWith()
@JsonSerializable()
class AppThemeState {
  AppThemeState({required this.mode, required this.color});

  factory AppThemeState.fromJson(JsonMap json) => _$AppThemeStateFromJson(json);

  @ThemeModeJsonConverter()
  final ThemeMode mode;

  @ColorJsonConverter()
  final Color color;

  ThemeData _getTheme(Brightness brightness) => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: brightness,
        ),
        useMaterial3: true,
      ).useSystemChineseFont(brightness);

  ThemeData get lightTheme => _getTheme(Brightness.light);
  ThemeData get darkTheme => _getTheme(Brightness.dark);

  JsonMap toJson() => _$AppThemeStateToJson(this);
}

class AppThemeNotifier extends StateNotifier<AppThemeState> {
  AppThemeNotifier() : super(_loadInitialState());

  static AppThemeState _loadInitialState() {
    AppThemeState? data;
    try {
      data = prefs.theme;
    } catch (e) {
      e.printError();
    }
    return data ?? AppThemeState(mode: ThemeMode.system, color: Colors.blue);
  }

  Future<bool> _saveState() => prefs.setTheme(state);

  void updateMode(ThemeMode? mode) {
    state = state.copyWith(mode: mode);
    _saveState();
  }

  void updateColor(Color? color) {
    state = state.copyWith(color: color);
    _saveState();
  }
}

final appThemeProvider =
    StateNotifierProvider<AppThemeNotifier, AppThemeState>((ref) {
  return AppThemeNotifier();
});
