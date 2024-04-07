import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<File?> filePicker([List<String>? allowedExtensions]) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
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
  String? selectedDirectory =
      await FilePicker.platform.getDirectoryPath(lockParentWindow: true);

  if (selectedDirectory == null) {
    return null;
  }
  return File(selectedDirectory);
}
