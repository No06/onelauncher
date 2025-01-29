import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart';

Future<void> extractFileToDiskAndExclude(
  String inputPath,
  String outputPath, {
  List<String>? excludeFiles,
  String? password,
}) async {
  final inputStream = InputFileStream(inputPath);
  final archive = ZipDecoder().decodeBuffer(inputStream, password: password);

  for (final file in archive) {
    final filename = file.name;
    if (excludeFiles != null && _isExcluded(filename, excludeFiles)) {
      continue;
    }
    await Directory(outputPath).create(recursive: true);
    if (file.isFile) {
      final data = file.content as Uint8List;
      File(join(outputPath, filename))
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    } else {
      await Directory(join(outputPath, filename)).create(recursive: true);
    }
  }
}

bool _isExcluded(String filename, List<String> excludeFiles) {
  for (final excludeFile in excludeFiles) {
    if (filename.startsWith(excludeFile)) {
      return true;
    }
  }
  return false;
}
