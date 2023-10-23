class JavaVersionNotFoundException implements Exception {
  const JavaVersionNotFoundException(this.path);

  final String path;

  @override
  String toString() => path;
}
