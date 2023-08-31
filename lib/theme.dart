import 'dart:math';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'theme.g.dart';

final kBorderRadius = BorderRadius.circular(7.5);
final kMediaBorderRadius = BorderRadius.circular(10);
final kLagerBorderRadius = BorderRadius.circular(12.5);

Color colorWithValue(Color color, double value) {
  final hsvColor = HSVColor.fromColor(color);
  return hsvColor.withValue(min(max(hsvColor.value + value, -1), 1)).toColor();
}

@JsonSerializable()
final class AppTheme {
  AppTheme({
    this.mode = ThemeMode.system,
    this.color = SeedColor.blue,
  });

  ThemeMode mode;
  SeedColor color;

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

  factory AppTheme.fromJson(Map<String, dynamic> json) =>
      _$AppThemeFromJson(json);

  Map<String, dynamic> toJson() => _$AppThemeToJson(this);
}

@JsonEnum()
enum SeedColor {
  blue(color: Colors.blue);

  const SeedColor({required this.color});

  final Color color;
}
