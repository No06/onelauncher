import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/version/librarie/common_librarie.dart';
import 'package:one_launcher/models/game/version/librarie/maven_librarie.dart';
import 'package:one_launcher/models/game/version/librarie/natives_librarie.dart';
import 'package:path/path.dart';

part 'librarie.g.dart';

// TODO: 解析json字段extract
@JsonSerializable()
class Librarie {
  Librarie({required this.name}) {
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

  String getPath(String gameLibrariesPath) => join(gameLibrariesPath, jarPath);
  Future<bool> exists(String gameLibrariesPath) async =>
      await File(getPath(gameLibrariesPath)).exists();

  static List<String> _splitPackageName(String packageName) {
    List<String> parts = packageName.split(':');
    if (parts.length > 4 || parts.length < 3) {
      throw ArgumentError(
          'packageName must have three parts separated by colons');
    }
    return parts;
  }

  factory Librarie.fromJson(Map<String, dynamic> json) {
    if (json['natives'] != null) {
      return NativesLibrarie.fromJson(json);
    }
    if (json['downloads'] != null) {
      return CommonLibrarie.fromJson(json);
    }
    if (json['url'] != null) {
      return MavenLibrarie.fromJson(json);
    }
    throw Exception("未知资源类型");
  }
}
