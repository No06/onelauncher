import 'dart:io';

import 'package:get/utils.dart';
import 'package:one_launcher/models/game/java_version.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/models/version.dart';
import 'package:one_launcher/utils/exceptions/java_release_file_not_found.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';

part 'java.g.dart';

@JsonSerializable()
class Java {
  Java(this.path, {this.args = ""}) {
    version = _getVersion();
  }

  final String path;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late final String version;

  JavaVersion get versionNumber {
    final split = version.split('.');
    var major = split[0];
    var minor = split.elementAtOrNull(1) ?? "-1";
    var revision = split.elementAtOrNull(2) ?? "-1";
    // 将版本号类似 1.8.0_352 转换为 8.0.352
    if (int.parse(split[0]) == 1) {
      final revisionSplit = revision.split('_');
      major = minor;
      minor = revisionSplit[0];
      if (revisionSplit.length > 1) {
        revision = revisionSplit[1];
      }
      return JavaVersion(
        major: int.parse(major),
        minor: toInt(minor),
        revision: toInt(revision),
      );
    }

    return JavaVersion.fromString(
        split.reduce((value, element) => "$value.$element"));
  }

  final String args;

  String _getVersion() {
    try {
      return _getVersionByReleaseFile();
    } catch (e) {
      e.printError();
    }
    try {
      return _getVersionByRun();
    } catch (e) {
      e.printError();
    }
    return "unknown";
  }

  /// 从 Java 路径中的 release 文件中获取版本号
  String _getVersionByReleaseFile() {
    const javaVersionLine = "JAVA_VERSION=";
    final parentPath =
        path.substring(0, path.length - "/bin/$kJavaBinName".length);
    final releaseFile = File('$parentPath/release');

    try {
      final versionLine = releaseFile
          .readAsLinesSync()
          .firstWhere((line) => line.startsWith(javaVersionLine))
          .substring(javaVersionLine.length);
      const quoteLength = '"'.length;
      return versionLine.substring(
          quoteLength, versionLine.length - quoteLength);
    } catch (e) {
      throw JavaReleaseFileNotFound(path);
    }
  }

  /// 通过运行二进制文件获取版本号
  String _getVersionByRun() {
    final parentPath = path.substring(0, path.length - kJavaBinName.length);
    final javacBinName = Platform.isWindows ? "javac.exe" : "javac";
    final javacPath = join(parentPath, javacBinName);
    ProcessResult result = Process.runSync(javacPath, ["-version"]);
    final stdout = result.stdout as String;
    final stderr = result.stderr as String;
    if (result.exitCode != 0) {
      throw Exception("Command Error: $stderr");
    }
    try {
      final resultStr = (stdout.isEmpty ? stderr : stdout);
      return resultStr.substring("javac ".length).trim();
    } catch (e) {
      return "unknown";
    }
  }

  factory Java.fromJson(JsonMap json) => _$JavaFromJson(json);

  JsonMap toJson() => _$JavaToJson(this);

  @override
  int get hashCode => path.hashCode;

  @override
  bool operator ==(Object other) => other is Java && path == other.path;
}
