extension StringExtension on String {
  bool get isNum => num.tryParse(this) != null;
}
