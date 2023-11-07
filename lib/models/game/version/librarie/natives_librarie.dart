import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/version/librarie/common_librarie.dart';
import 'package:one_launcher/models/game/version/librarie/downloads.dart';
import 'package:one_launcher/models/game/version/librarie/extract.dart';
import 'package:one_launcher/models/game/version/os.dart';
import 'package:one_launcher/models/game/version/rule.dart';
import 'package:one_launcher/utils/extract_file_to_disk_and_exclude.dart';
import 'package:path/path.dart';

part 'natives_librarie.g.dart';

@JsonSerializable()
class NativesLibrarie extends CommonLibrarie {
  NativesLibrarie({
    required super.name,
    required super.downloads,
    super.rules,
    required this.natives,
    this.extractRule,
  });

  static final currentOsName = OsName.fromName(Platform.operatingSystem);

  final Map<OsName, String> natives;
  @JsonKey(name: "extract")
  final ExtractRule? extractRule;

  String? get osNameString => natives[currentOsName];

  Future<void> extract(String gameLibrariesPath, String outputPath) async {
    final nativePath = getNativePath(gameLibrariesPath);
    if (nativePath == null) return;
    debugPrint(
        "extract: $nativePath, to: $outputPath, exclude: ${extractRule?.exclude}");
    // extractFileToDiskAndExclude(nativePath, outputPath,
    //     excludeFiles: extractRule?.exclude);
  }

  String? getNativePath(String gameLibrariesPath) {
    if (currentOsName == OsName.unknown) {
      throw Exception("Unsupported system: ${Platform.operatingSystem}");
    }
    final nativePath = downloads.classifiers?[osNameString]?.path;
    if (nativePath == null) return null;
    return join(gameLibrariesPath, nativePath);
  }

  factory NativesLibrarie.fromJson(Map<String, dynamic> json) =>
      _$NativesLibrarieFromJson(json);
}
