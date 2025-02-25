import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_launcher/config/preference.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';

class AppThemeState {
  AppThemeState({required this.mode, required this.color});

  factory AppThemeState.fromJson(JsonMap json) => AppThemeState(
        mode: ThemeMode.values[json['mode'] as int],
        color: Color(json['color'] as int),
      );
  final ThemeMode mode;
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

  AppThemeState copyWith({ThemeMode? mode, Color? color}) {
    return AppThemeState(
      mode: mode ?? this.mode,
      color: color ?? this.color,
    );
  }

  JsonMap toJson() => {
        "mode": mode.index,
        "color": color.value,
      };
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
