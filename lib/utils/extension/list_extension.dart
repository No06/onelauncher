extension ListExtension<T> on List<T> {
  void addIf(bool condition, T value) {
    if (condition) add(value);
  }

  /// example: ```[1, 1, 1].insertJoin(0) => [1, 0, 1, 0, 1]```
  void joinWith(T value) {
    for (var i = 1; i < length; i += 2) {
      insert(i, value);
    }
  }
}
