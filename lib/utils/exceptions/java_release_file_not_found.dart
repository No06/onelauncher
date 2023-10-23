class JavaReleaseFileNotFound implements Exception {
  const JavaReleaseFileNotFound(this.path);

  final String path;

  @override
  String toString() => path;
}
