import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_launcher/main.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';

class AppThemeState {
  final ThemeMode mode;
  final Color color;

  AppThemeState({required this.mode, required this.color});

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

  factory AppThemeState.fromJson(JsonMap json) => AppThemeState(
        mode: ThemeMode.values[json['mode']],
        color: Color(json['color']),
      );
}

class AppThemeNotifier extends StateNotifier<AppThemeState> {
  AppThemeNotifier() : super(_loadInitialState());

  static const storageKey = "appTheme";

  static _loadInitialState() {
    final storedData = storage.read<JsonMap>(storageKey);
    try {
      if (storedData != null) return AppThemeState.fromJson(storedData);
    } catch (e) {
      e.printError();
    }
    return AppThemeState(mode: ThemeMode.system, color: Colors.blue);
  }

  void _saveState() {
    storageKey.printInfo("Save storage");
    storage.write(storageKey, state.toJson());
  }

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
