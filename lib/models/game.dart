import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as p;

import 'game_setting_config.dart';

part 'game.g.dart';

/// Game对象 存储一个游戏的信息
///
/// [path] 传入路径
@JsonSerializable()
class Game {
  final String path; // .minecraft/version/xxx

  String? _version;
  String? get version => _version;
  String? _forge;
  String? get forge => _forge;
  String? _fabric;
  String? get fabric => _fabric;
  String? _liteloader;
  String? get liteloader => _liteloader;
  String? _quilt;
  String? get quilt => _quilt;
  String? _optifine;
  String? get optifine => _optifine;
  String? _type;
  String? get type => _type;

  late final _jsonData = jsonDecode(
      File(p.join(path, "${p.basename(path)}.json")).readAsStringSync()) as Map;
  get jsonData => _jsonData;

  late final _jar = _jsonData['jar'];
  get jar => _jar;

  late final _id = _jsonData['id'];
  get id => _id;

  late final _javaMajorVersion = _jsonData['javaVersion']['majorVersion'];
  get javaMajorVersion => _javaMajorVersion;

  bool useGlobalSetting;
  GameSettingConfig? setting;

  Game(
    this.path, {
    this.useGlobalSetting = true,
    this.setting,
  }) {
    readPatches();
  }

  dynamic readFromJar(String fileName, String key) {
    final decodeZip = ZipDecoder().decodeBytes(File(jar).readAsBytesSync());
    final file = decodeZip.findFile(fileName);
    if (file == null) {
      return null;
    }
    final by = jsonDecode(utf8.decode(file.content));
    return by[key];
  }

  void readPatches() {
    final patchesJsonData = _jsonData['patches'] as List;

    for (Map patch in patchesJsonData) {
      final id = patch['id'];
      switch (id) {
        case "game":
          _version = patch['version'];
          _type = patch['type'];
        case "forge":
          _forge = patch['version'];
        case "optifine":
          _optifine = patch['version'];
      }
    }
  }

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  Map<String, dynamic> toJson() => _$GameToJson(this);

  @override
  String toString() {
    return 'Version: $version';
  }
}
