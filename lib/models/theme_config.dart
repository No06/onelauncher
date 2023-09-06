import 'dart:math';

import 'package:beacon/consts.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'theme_config.g.dart';

Color colorWithValue(Color color, double value) {
  final hsvColor = HSVColor.fromColor(color);
  return hsvColor.withValue(min(max(hsvColor.value + value, -1), 1)).toColor();
}

@JsonSerializable()
final class AppThemeConfig extends ChangeNotifier {
  AppThemeConfig({ThemeMode? mode, SeedColor? color})
      : _mode = ValueNotifier(mode ?? kDefaultThemeMode),
        _color = ValueNotifier(color ?? kDefaultSeedColor),
        super() {
    _mode.addListener(notifyListeners);
    _color.addListener(notifyListeners);
  }

  ValueNotifier<ThemeMode> _mode;

  ValueNotifier<SeedColor> _color;

  ThemeMode get mode => _mode.value;
  set mode(ThemeMode newVal) => _mode.value = newVal;

  SeedColor get color => _color.value;
  set color(SeedColor newVal) => _color.value = newVal;

  ThemeData lightTheme() {
    return ThemeData(
      fontFamily: 'MiSans',
      colorScheme: ColorScheme.fromSeed(
        seedColor: color.color,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  ThemeData darkTheme() {
    return ThemeData(
      fontFamily: 'MiSans',
      colorScheme: ColorScheme.fromSeed(
        seedColor: color.color,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }

  factory AppThemeConfig.fromJson(Map<String, dynamic> json) =>
      _$AppThemeConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppThemeConfigToJson(this);
}

@JsonEnum()
enum SeedColor {
  blue(Colors.blue);

  const SeedColor(this.color);
  final Color color;
}
