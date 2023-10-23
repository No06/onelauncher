import 'dart:io';

import 'package:get/utils.dart';
import 'package:one_launcher/utils/exceptions/java_release_file_not_found.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';

part 'java.g.dart';

@JsonSerializable()
class Java {
  Java(this.path, {String? versionNumber, this.args = ""}) {
    if (versionNumber != null) {
      this.versionNumber = versionNumber;
    } else {
      this.versionNumber = _getVersion();
    }
  }

  final String path;
  late final String versionNumber;
  final String args;

  String get version {
    final regex1 = RegExp(r"(\d+)");
    final regex2 = RegExp(r"\.(\d+)");
    final match1 = regex1.firstMatch(versionNumber);
    final match2 = regex2.firstMatch(versionNumber);
    if (match1 != null) {
      if (match1.group(1) == "1" && match2 != null) {
        return "${match2.group(1)}";
      } else {
        return "${match1.group(1)}";
      }
    } else {
      return "unknown";
    }
  }

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

  factory Java.fromJson(Map<String, dynamic> json) => _$JavaFromJson(json);

  Map<String, dynamic> toJson() => _$JavaToJson(this);

  @override
  int get hashCode => path.hashCode;

  @override
  bool operator ==(Object other) => other is Java && path == other.path;
}
