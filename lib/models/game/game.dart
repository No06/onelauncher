import 'dart:io';
import 'dart:convert';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/main.dart';
import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/config/app_config.dart';
import 'package:one_launcher/models/game/version/librarie/common_librarie.dart';
import 'package:one_launcher/models/game/version/librarie/librarie.dart';
import 'package:one_launcher/models/game/version/librarie/maven_librarie.dart';
import 'package:one_launcher/models/game/version/librarie/natives_librarie.dart';
import 'package:one_launcher/models/game/version/version.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/utils/random_string.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:system_info2/system_info2.dart';

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
        _librariesPath = (join(mainPath, "libraries")),
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
  Version _version;
  Version get version => _version;

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
  /// 如: /home/onelauncher/.minecraft/libraries
  final String _librariesPath;
  @JsonKey(includeToJson: false)
  String get librariesPath => _librariesPath;

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

  String get assetIndex => "5";

  /// 获取游戏拼接资源 -cp 字符串
  String get argCp {
    const prefix = "-cp";
    final libraries = version.libraries;
    final librariesJars = libraries.map((lib) => lib.jarPath).toList()
      ..add(clientPath);
    return "$prefix ${librariesJars.join(';')}";
  }

  /// 获取游戏native资源解压路径
  /// 如: /home/onelauncher/.minecraft/version/1.x.x/natives-windows-x86_64
  String get nativeLibrarieExtractPath {
    final architecture = SysInfo.kernelArchitecture.name;
    final bitness = SysInfo.kernelBitness;
    return join(
        path, "natives-${Platform.operatingSystem}-${architecture}_$bitness");
  }

  bool get isModVersion =>
      _version.mainClass != "net.minecraft.client.main.Main";

  /// 生成随机本地存储的路径
  Future<String> get randomOutputPath async {
    final random = generateRandomString(8);
    return join((await getApplicationDocumentsDirectory()).path,
        "minecraft-${_version.id}-natives-$random");
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

  /// 刷新 [version] 游戏文件内容
  void freshVersion() => _version = _getVersionFromPath(path);

  /// 将游戏配置保存至本地
  void saveConfig() {
    final config = File(path + kGameConfigName);
    final json = const JsonEncoder.withIndent('  ').convert(this);
    config.writeAsStringSync(json);
  }

  /// 获取启动参数
  Future<String> getStartupCommand(Account account) async {
    final java = setting.java;
    if (java == null) {
      throw Exception("启动游戏必须要安装Java");
    }
    // 命令行参数
    final args = [
      // 设置相关
      GameArgument(java.path),
      GameArgument("-Xmx${setting.maxMemory}M"),
      GameArgument(setting.jvmArgs),
      // 设置相关end
      GameArgument(version.logging.client.argument, loggingPath),
      GameArgument("-Dminecraft.client.jar", clientPath),
      const GameArgument("-XX:HeapDumpPath",
          "MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump"),
      GameArgument("-Djava.library.path", nativeLibrarieExtractPath),
      GameArgument("-Djna.tmpdir", nativeLibrarieExtractPath),
      GameArgument("-Dorg.lwjgl.system.SharedLibraryExtractPath",
          nativeLibrarieExtractPath),
      GameArgument("-Dio.netty.native.workdir", nativeLibrarieExtractPath),
      const GameArgument("-Dminecraft.launcher.brand", appName),
      GameArgument("-Dminecraft.launcher.version", appInfo.version),
      GameArgument(argCp),
      GameArgument(version.mainClass),
      // 用户名
      GameArgument("--username ${account.displayName}"),
      // version
      GameArgument("--version ${version.id}"),
      // 游戏路径
      GameArgument("--gameDir $mainPath"),
      // 资源文件路径
      GameArgument("--assetsDir $assetsPath"),
      // 资源索引版本
      GameArgument("--assetIndex $assetIndex"),
      // UUID
      GameArgument("--uuid ${account.uuid}"),
      // token
      GameArgument("--accessToken ${account.accessToken}"),
      // 登录类型
      const GameArgument("--userType msa"),
      // 版本类型
      GameArgument("--versionType $appName ${appInfo.version}"),
      // 窗口长宽
      GameArgument("--width ${setting.width}"),
      GameArgument("--height ${setting.height}"),
    ];

    return args.map((arg) => arg.toString()).join(' ');
  }

  Map<String, dynamic> toJson() => _$GameToJson(this);

  /// 从指定路径读取文件序列化为 [Version]
  static Version _getVersionFromPath(String path) {
    return Version.fromJson(
      jsonDecode(File(join(path, "${basename(path)}.json")).readAsStringSync()),
    );
  }
}

/// 游戏运行的参数
class GameArgument {
  /// 传入字符串，或者
  /// 如：
  const GameArgument(this.key, [this.value]);

  static const connector = "=";
  final String key;
  final String? value;

  @override
  String toString() => value == null ? key : "$key$connector$value";
}
