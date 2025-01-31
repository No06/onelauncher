import 'dart:math';

extension NumExtension on num {
  double toKB() => this / 1024;
  double toMB() => toKB() / 1024;
  double toGB() => toMB() / 1024;

  /// 保留 N 位小数:
  /// ```dart
  /// 1.23456789.toDecimal(2); // 1.23
  /// ```
  double toDecimal([int fractionalDigits = 1]) =>
      (this * pow(10, fractionalDigits)).truncate() / pow(10, fractionalDigits);
}
