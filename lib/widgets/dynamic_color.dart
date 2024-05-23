import 'dart:math';

import 'package:flutter/material.dart';

Color colorWithValue(Color color, double value) {
  final hsvColor = HSVColor.fromColor(color);
  return hsvColor.withValue(min(max(hsvColor.value + value, -1), 1)).toColor();
}

Color dynamicColorWithValue(
  Color color,
  double value,
  double opposite,
  Brightness brightness,
) {
  return colorWithValue(
    color,
    brightness == Brightness.light ? value : opposite,
  );
}

extension ColorExtension on Color {
  Color withValue(double value) => colorWithValue(this, value);
}
