import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/data/library/artifact.dart';
import 'package:one_launcher/models/game/data/library/common_library.dart';
import 'package:one_launcher/models/game/data/library/downloads.dart';
import 'package:one_launcher/models/game/data/library/extract.dart';
import 'package:one_launcher/models/game/data/os.dart';
import 'package:one_launcher/models/game/data/rule.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';
import 'package:one_launcher/utils/file/extract_file_to_disk_and_exclude.dart';
import 'package:one_launcher/utils/sysinfo/os_architecture.dart';
import 'package:one_launcher/utils/sysinfo/sysinfo.dart';
import 'package:path/path.dart';

part 'natives_library.g.dart';

@JsonSerializable()
class NativesLibrary extends CommonLibrary {
  NativesLibrary({
    required super.name,
    required super.downloads,
    required this.natives,
    super.rules,
    this.extractRule,
  });

  factory NativesLibrary.fromJson(JsonMap json) =>
      _$NativesLibraryFromJson(json);

  static final currentOsName = OsName.fromName(Platform.operatingSystem);

  String getNativePath(String gameLibrariesPath) =>
      join(gameLibrariesPath, artifact?.path);

  final Map<OsName, String> natives;
  @JsonKey(name: "extract")
  final ExtractRule? extractRule;

  Artifact? get artifact {
    final classifiers = downloads.classifiers;
    if (Platform.isLinux) return classifiers?.linux;
    if (Platform.isMacOS) return classifiers?.osx;
    if (Platform.isWindows) {
      if (classifiers?.windows != null) {
        return classifiers?.windows;
      }
      if (Sysinfo.osArchitecture == OsArchitecture.bit32) {
        return classifiers?.windows_32;
      }
      if (Sysinfo.osArchitecture == OsArchitecture.bit64) {
        return classifiers?.windows_64;
      }
    }
    return null;
  }

  /// 解压 natives 资源
  /// [libraryPath] 应传入如 /home/onelauncher/.minecraft/libraries
  /// 解压到 [outputPath] 路径
  Future<void> extract(String libraryPath, String outputPath) async {
    if (!isAllowed) "Pass extract: $name".printInfo();

    "extract: $name, to: $outputPath, exclude: ${extractRule?.exclude}"
        .printInfo();

    final nativePath = artifact?.path;
    if (nativePath == null) return;
    final path = join(libraryPath, nativePath);
    await extractFileToDiskAndExclude(
      path,
      outputPath,
      excludeFiles: extractRule?.exclude,
    );
  }

  String? get osNameString => natives[currentOsName];
  @override
  JsonMap toJson() => _$NativesLibraryToJson(this);
}
