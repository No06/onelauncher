import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/game/data/game_data.dart';
import 'package:one_launcher/models/game/game_version.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/provider/game_setting_provider.dart';
import 'package:path/path.dart';

part 'game.g.dart';

@immutable
@JsonSerializable(createToJson: false)
class Game {
  Game(
    String mainPath,
    String versionPath, {
    this.setting,
  })  : _mainPath = mainPath,
        _versionPath = versionPath,
        _data = _getDataFromPath(join(mainPath, versionPath));

  factory Game.fromJson(
    String librariesPath,
    String versionPath,
    JsonMap json,
  ) {
    json
      ..addAll({"librariesPath": librariesPath})
      ..addAll({"versionPath": versionPath});
    return _$GameFromJson(json);
  }

  /// 获取游戏native资源解压路径
  /// 如: /home/onelauncher/.minecraft/version/1.x.x/natives-windows-x86_64
  String get nativesPath => join(path, "natives-${Platform.operatingSystem}");

  /// 游戏设置配置文件
  final GameSetting? setting;

  /// 游戏文件 1.x.x.json序列化内容
  final GameData _data;

  /// 主路径
  /// 如: /home/onelauncher/.minecraft
  final String _mainPath;

  /// version文件夹路径
  /// 如: version/1.x.x
  final String _versionPath;

  GameData get data => _data;

  // 游戏版本号
  String? get version => data.clientVersion ?? getVersionFromJar();

  String? getVersionFromJar() {
    final jarFile = File("$mainPath/$versionPath/${_data.jarFile}");
    if (!jarFile.existsSync()) return null;

    final versionFile = ZipDecoder()
        .decodeBytes(
          File("$mainPath/$versionPath/${_data.jarFile}").readAsBytesSync(),
        )
        .findFile("version.json");
    if (versionFile == null) return null;

    final versionFileContent = versionFile.content as Uint8List?;
    if (versionFileContent == null) return null;

    final json = jsonDecode(utf8.decode(versionFileContent)) as JsonMap;
    return json["id"] as String?;
  }

  /// 游戏版本
  GameVersion? get versionNumber {
    final split = version?.split('.');
    if (split == null) return null;
    final major = split[0];
    final minor = split.elementAtOrNull(1);
    final revision = split.elementAtOrNull(2);

    int? toInt(String? value) => value != null ? int.tryParse(value) : null;
    if (int.tryParse(major) == null) return null;
    return GameVersion(
      major: int.parse(major),
      minor: toInt(minor),
      revision: toInt(revision),
    );
  }

  @JsonKey(includeToJson: false)
  String get mainPath => _mainPath;

  @JsonKey(includeToJson: false)
  String get versionPath => _versionPath;

  /// 游戏资源库路径
  /// 如: /home/onelauncher/.minecraft/libraries
  @JsonKey(includeToJson: false)
  String get librariesPath => join(mainPath, "libraries");

  /// 游戏路径
  /// 如: /home/onelauncher/.minecraft/version/1.x.x
  String get path => join(mainPath, versionPath);

  /// 游戏相对路径
  /// 如: .minecraft/version/1.x.x
  String get relativePath => join(kGameDirectoryName, versionPath);

  /// 客户端路径
  /// 如: /home/onelauncher/.minecraft/version/1.x.x/1.x.x.jar
  String get clientPath => join(path, data.jarFile);

  /// 客户端相对路径
  /// 如: .minecraft/version/1.x.x/1.x.x.jar
  String get clientRelativePath => join(relativePath, data.jarFile);

  /// log 配置文件路径
  /// 如: /home/onelauncher/.minecraft/version/1.x.x/log4j2.xml
  String? get loggingPath {
    var logFile = data.logging?.client?.file.id;
    logFile ??= data.gamePatch?.logging?.client?.file.id;
    return logFile == null ? null : join(path, logFile);
  }

  /// 游戏资源路径
  /// 如: /home/onelauncher/.minecraft/assets
  String get assetsPath => join(_mainPath, "assets");

  String? get assetIndex => data.assetIndex?.id;

  bool get isModVersion => _data.mainClass != "net.minecraft.client.main.Main";

  /// 刷新 [data] 游戏文件内容
  Game fresh() => Game(_mainPath, _versionPath, setting: setting);

  /// 从指定路径读取文件序列化为 [GameData]
  static GameData _getDataFromPath(String path) => GameData.fromJson(
        jsonDecode(
          File(join(path, "${basename(path)}.json")).readAsStringSync(),
        ) as JsonMap,
      );

  @override
  int get hashCode => data.id.hashCode;

  @override
  bool operator ==(Object other) => other is Game && path == other.path;
}

/// 游戏运行的参数
class GameArgument {
  const GameArgument(this.key, [this.value]);

  static const connector = "=";

  final String key;
  final String? value;

  @override
  String toString() => value == null ? key : "$key$connector$value";
}
