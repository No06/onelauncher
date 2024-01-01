import 'dart:io';
import 'dart:convert';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/offline_account.dart';
import 'package:one_launcher/models/config/app_config.dart';
import 'package:one_launcher/models/game/version/librarie/common_librarie.dart';
import 'package:one_launcher/models/game/version/librarie/librarie.dart';
import 'package:one_launcher/models/game/version/librarie/maven_librarie.dart';
import 'package:one_launcher/models/game/version/librarie/natives_librarie.dart';
import 'package:one_launcher/models/game/version/version.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/java.dart';
import 'package:one_launcher/utils/random_string.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../config/game_setting_config.dart';

part 'game.g.dart';

typedef ResultMap = Map<Librarie, bool>;

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
        _librariesPath = (join(mainPath, librariesDirectory)),
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

  static const assetsDirectory = "assets";
  static const librariesDirectory = "libraries";
  static const mainClass = "net.minecraft.client.main.Main";

  /// 资源路径
  final String _librariesPath;

  /// 主路径
  /// 如: /home/onelauncher/.minecraft/version
  final String _mainPath;

  /// 独立的游戏配置
  GameSettingConfig? _setting;

  ValueNotifier<bool> _useGlobalSetting;
  Version _version;

  /// version文件夹路径
  final String _versionPath;

  @JsonKey(includeToJson: false)
  String get mainPath => _mainPath;

  @JsonKey(includeToJson: false)
  String get versionPath => _versionPath;

  @JsonKey(includeToJson: false)
  String get librariesPath => _librariesPath;

  String get path => join(_mainPath, _versionPath);

  Version get version => _version;

  GameSettingConfig get setting => _setting ?? appConfig.gameSetting;

  void freshVersion() => _version = _getVersionFromPath(path);

  /// 将游戏配置保存至本地
  void saveConfig() {
    final config = File(path + kGameConfigName);
    final json = const JsonEncoder.withIndent('  ').convert(this);
    config.writeAsStringSync(json);
  }

  String get assetsPath => join(_mainPath, assetsDirectory);

  String get loggingFilePath =>
      join(assetsPath, _version.logging.client.file.id);

  bool get isModVersion => _version.mainClass != mainClass;

  /// 生成随机本地存储的路径
  Future<String> get randomOutputPath async {
    while (true) {
      final random = generateRandomString(8);
      final outputPath = join((await getApplicationDocumentsDirectory()).path,
          "minecraft-${_version.id}-natives-$random");
      if (!await Directory(outputPath).exists()) {
        return outputPath;
      }
    }
  }

  /// 检索游戏资源 返回游戏资源库中不存在的资源
  Stream<Librarie> get retrieveLibraries async* {
    String? outputPath;
    for (var lib in version.libraries) {
      if (lib is MavenLibrarie || lib is CommonLibrarie && lib.isAllowed) {
        if (lib is NativesLibrarie) {
          outputPath ??= await randomOutputPath;
          await lib.extract(_librariesPath, outputPath);
          continue;
        }
        if (!await lib.exists(_librariesPath)) yield lib;
      }
    }
  }

  /// 获取启动参数
  String getStartupCommandLine({
    required Java java,
    required Account account,
  }) {
    // TODO: 正版
    if (account is! OfflineAccount) {
      throw UnimplementedError();
    }
    return '"${java.path}" -XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump';
  }

  Map<String, dynamic> toJson() => _$GameToJson(this);

  /// 从指定路径读取文件序列化为 [Version]
  static Version _getVersionFromPath(String path) {
    return Version.fromJson(
      jsonDecode(File(join(path, "${basename(path)}.json")).readAsStringSync()),
    );
  }
}
