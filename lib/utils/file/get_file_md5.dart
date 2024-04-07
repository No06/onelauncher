import 'dart:io';

import 'package:crypto/crypto.dart';

Future<Digest> getFileMd5(String filePath) async {
  final file = File(filePath);
  final fileBytes = await file.readAsBytes();
  return md5.convert(fileBytes);
}
