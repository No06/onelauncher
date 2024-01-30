import 'dart:io';
import 'dart:convert';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/config/app_config.dart';
import 'package:one_launcher/models/game/version/library/library.dart';
import 'package:one_launcher/models/game/version/game_data.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/version_number/version_number.dart';
import 'package:path/path.dart';

import '../config/game_setting_config.dart';

part 'game.g.dart';

typedef ResultMap = Map<Library, bool>;

@JsonSerializable()
class Game {
  Game(
    String mainPath,
    String versionPath, {
    bool? useGlobalSetting,
    GameSettingConfig? setting,
  })  : _mainPath = mainPath,
        _versionPath = versionPath,
        _useGlobalSetting = ValueNotifier(useGlobalSetting ?? false),
        _librarysPath = (join(mainPath, "libraries")),
        _setting = setting,
        _version = _getVersionFromPath(join(mainPath, versionPath)) {
    _useGlobalSetting.addListener(saveConfig);
    _setting?.addListener(saveConfig);
  }

  factory Game.fromJson(
    String librariesPath,
    String versionPath,
    Map<String, dynamic> json,
  ) {
    json.addAll({"librariesPath": librariesPath});
    json.addAll({"versionPath": versionPath});
    return _$GameFromJson(json);
  }

  /// 游戏设置配置文件
  GameSettingConfig? _setting;
  GameSettingConfig get setting => _setting ?? appConfig.gameSetting;

  /// 是否使用全局游戏设置
  ValueNotifier<bool> _useGlobalSetting;

  /// 游戏文件 1.x.x.json序列化内容
  GameData _version;
  GameData get version => _version;

  /// 游戏版本
  VersionNumber get versionNumber {
    final split = version.id.split('.');
    final major = split[0];
    final minor = split.elementAtOrNull(1);
    final revision = split.elementAtOrNull(2);

    int? toInt(String? value) => value != null ? int.parse(value) : null;
    return VersionNumber(
      major: int.parse(major),
      minor: toInt(minor),
      revision: toInt(revision),
    );
  }

  /// 主路径
  /// 如: /home/onelauncher/.minecraft
  final String _mainPath;
  @JsonKey(includeToJson: false)
  String get mainPath => _mainPath;

  /// version文件夹路径
  /// 如: version/1.x.x
  final String _versionPath;
  @JsonKey(includeToJson: false)
  String get versionPath => _versionPath;

  /// 游戏资源库路径
  /// 如: /home/onelauncher/.minecraft/librarys
  final String _librarysPath;
  @JsonKey(includeToJson: false)
  String get librariesPath => _librarysPath;

  /// 游戏路径
  /// 如: /home/onelauncher/.minecraft/version/1.x.x
  String get path => join(mainPath, versionPath);

  /// 游戏相对路径
  /// 如: .minecraft/version/1.x.x
  String get relativePath => join(kGameDirectoryName, versionPath);

  /// 客户端路径
  /// 如: /home/onelauncher/.minecraft/version/1.x.x/1.x.x.jar
  String get clientPath => join(path, version.jarFile);

  /// 客户端相对路径
  /// 如: .minecraft/version/1.x.x/1.x.x.jar
  String get clientRelativePath => join(relativePath, version.jarFile);

  /// log 配置文件路径
  /// 如: /home/onelauncher/.minecraft/version/1.x.x/log4j2.xml
  String get loggingPath => join(path, version.logging.client.file.id);

  /// 游戏资源路径
  /// 如: /home/onelauncher/.minecraft/assets
  String get assetsPath => join(_mainPath, "assets");

  String? get assetIndex => version.assetIndex.id;

  /// 获取游戏native资源解压路径
  /// 如: /home/onelauncher/.minecraft/version/1.x.x/natives-windows-x86_64
  String get nativeLibraryExtractPath =>
      join(path, "natives-${Platform.operatingSystem}");

  bool get isModVersion =>
      _version.mainClass != "net.minecraft.client.main.Main";

  /// 刷新 [version] 游戏文件内容
  void freshVersion() => _version = _getVersionFromPath(path);

  /// 将游戏配置保存至本地
  void saveConfig() {
    final config = File(path + kGameConfigName);
    final json = const JsonEncoder.withIndent('  ').convert(this);
    config.writeAsStringSync(json);
  }

  Map<String, dynamic> toJson() => _$GameToJson(this);

  /// 从指定路径读取文件序列化为 [GameData]
  static GameData _getVersionFromPath(String path) {
    return GameData.fromJson(
      jsonDecode(File(join(path, "${basename(path)}.json")).readAsStringSync()),
    );
  }
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
