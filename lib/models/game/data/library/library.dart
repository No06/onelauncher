import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/data/library/common_library.dart';
import 'package:one_launcher/models/game/data/library/maven_library.dart';
import 'package:one_launcher/models/game/data/library/natives_library.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:path/path.dart';

part 'library.g.dart';

@immutable
@JsonSerializable(createFactory: false)
class Library {
  Library({required this.name}) {
    final result = _splitPackageName(name);
    _groupId = result[0];
    _artifactId = result[1];
    _version = result[2];
    if (result.length == 4) {
      _classifier = result[3];
    } else {
      _classifier = null;
    }
  }

  factory Library.fromJson(JsonMap json) {
    if (json['natives'] != null) {
      return NativesLibrary.fromJson(json);
    }
    if (json['downloads'] != null) {
      return CommonLibrary.fromJson(json);
    }
    if (json['url'] != null) {
      return MavenLibrary.fromJson(json);
    }
    if (json['name'] != null) {
      return Library(name: json['name'] as String);
    }
    throw Exception("未知资源类型");
  }

  final String name;

  late final String _groupId;
  late final String _artifactId;
  late final String _version;
  late final String? _classifier;
  String get groupId => _groupId;
  String get artifactId => _artifactId;
  String get version => _version;
  String? get classifier => _classifier;

  String get path {
    final splits = _groupId.split('.');
    return joinAll(splits);
  }

  String get jarName =>
      "$_artifactId-$_version${_classifier == null ? '' : '-$_classifier'}.jar";
  String get jarPath => join(path, artifactId, version, jarName);

  String getFullPath(String gameLibrariesPath) =>
      join(gameLibrariesPath, jarPath);
  bool existInGame(String gameLibrariesPath) =>
      File(getFullPath(gameLibrariesPath)).existsSync();

  @override
  bool operator ==(Object other) {
    if (other is! Library) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  static List<String> _splitPackageName(String packageName) {
    final parts = packageName.split(':');
    if (parts.length > 4 || parts.length < 3) {
      throw ArgumentError(
        'packageName must have three parts separated by colons',
      );
    }
    return parts;
  }
}
