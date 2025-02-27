import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

class ThemeModeJsonConverter extends JsonConverter<ThemeMode, int> {
  const ThemeModeJsonConverter();

  @override
  ThemeMode fromJson(int json) => ThemeMode.values[json];

  @override
  int toJson(ThemeMode object) => object.index;
}
