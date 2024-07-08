extension ListExtension<T> on List<T> {
  void addIf(bool condition, T value) {
    if (condition) add(value);
  }
}
