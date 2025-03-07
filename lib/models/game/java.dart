import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/java_version.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';
import 'package:one_launcher/utils/json/json_key_ignore.dart';
import 'package:path/path.dart';

part 'java.g.dart';

abstract class Java {
  const Java(this.path);

  factory Java.fromJson(JsonMap json) {
    if (json.isEmpty) {
      return const EmptyJava();
    }
    return _JavaImpl.fromJson(json);
  }

  factory Java.fromPath(String path) {
    if (path.isEmpty) {
      return const EmptyJava();
    }
    return _JavaImpl(path);
  }

  JsonMap toJson();

  final String path;

  String get version;
  JavaVersion get versionNumber;
}

@immutable
@JsonSerializable()
class _JavaImpl extends Java {
  _JavaImpl(super.path);

  factory _JavaImpl.fromJson(JsonMap json) => _$JavaImplFromJson(json);

  static final binName = Platform.isWindows ? "java.exe" : "java";

  @JsonKeyIgnore()
  late final String _version = _getVersion();

  @override
  String get version => _version;

  @override
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
        minor: int.tryParse(minor),
        revision: int.tryParse(revision),
      );
    }

    return JavaVersion.fromString(
      split.reduce((value, element) => "$value.$element"),
    );
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

  /// 从 Java 路径中的 release 文件中获取版本号
  String _getVersionByReleaseFile() {
    const javaVersionLine = "JAVA_VERSION=";
    final parentPath = path.substring(0, path.length - "/bin/$binName".length);
    final releaseFile = File('$parentPath/release');

    final versionLine = releaseFile
        .readAsLinesSync()
        .firstWhere((line) => line.startsWith(javaVersionLine))
        .substring(javaVersionLine.length);
    const quoteLength = '"'.length;
    return versionLine.substring(quoteLength, versionLine.length - quoteLength);
  }

  /// 通过运行二进制文件获取版本号
  String _getVersionByRun() {
    final parentPath = path.substring(0, path.length - binName.length);
    final javacBinName = Platform.isWindows ? "javac.exe" : "javac";
    final javacPath = join(parentPath, javacBinName);
    final result = Process.runSync(javacPath, ["-version"]);
    final stdout = result.stdout as String;
    final stderr = result.stderr as String;
    if (result.exitCode != 0) {
      throw Exception("Command Error: $stderr");
    }

    final resultStr = (stdout.isEmpty ? stderr : stdout);
    return resultStr.substring("javac ".length).trim();
  }

  @override
  JsonMap toJson() => _$JavaImplToJson(this);

  @override
  int get hashCode => path.hashCode;

  @override
  bool operator ==(Object other) => other is _JavaImpl && path == other.path;
}

class EmptyJava extends Java {
  const EmptyJava() : super("");

  @override
  String get version => "unknown";

  @override
  JavaVersion get versionNumber =>
      JavaVersion(major: -1, minor: null, revision: null);

  @override
  JsonMap toJson() => {};
}
