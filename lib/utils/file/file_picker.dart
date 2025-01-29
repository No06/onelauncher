import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<File?> filePicker([List<String>? allowedExtensions]) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: allowedExtensions ?? ['*'],
    lockParentWindow: true,
  );

  if (result == null) {
    return null;
  }
  return File(result.files.single.path.toString());
}

Future<File?> folderPicker() async {
  final selectedDirectory =
      await FilePicker.platform.getDirectoryPath(lockParentWindow: true);

  if (selectedDirectory == null) {
    return null;
  }
  return File(selectedDirectory);
}
