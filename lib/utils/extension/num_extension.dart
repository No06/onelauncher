extension NumExtension on num {
  double toKB() => this / 1024;
  double toMB() => toKB() / 1024;
  double toGB() => toMB() / 1024;
}
