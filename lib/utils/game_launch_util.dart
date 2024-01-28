import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/main.dart';
import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/account_login_info.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/models/game/java.dart';
import 'package:one_launcher/models/game/version/librarie/common_librarie.dart';
import 'package:one_launcher/models/game/version/librarie/librarie.dart';
import 'package:one_launcher/models/game/version/librarie/maven_librarie.dart';
import 'package:one_launcher/models/game/version/librarie/natives_librarie.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:one_launcher/utils/random_string.dart';
import 'package:one_launcher/utils/sys_info/sys_info.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class GameLaunchUtil {
  GameLaunchUtil(this.game);

  final Game game;
  final List<NativesLibrary> _extractLibraries = [];
  AccountLoginInfo? loginInfo;
  Iterable<Library>? _allowedLibraries;
  Iterable<Library> get allowedLibraries =>
      _allowedLibraries ??= getAllowedLibraries();

  late final int _allocateMem;
  int get allocateMem => max(_allocateMem, 512); // 设置下限 512MB

  late final Java? java;

  /// 检查游戏启动环境
  /// 返回：错误信息
  List<String> checkEnvironment() {
    final messages = <String>[];
    // Java
    if (setJava() == null) {
      messages.add("未找到安装的Java，如已安装请检查环境变量是否设置正确。");
    }
    // 内存
    final maxMem = setMaxMem();
    late final int recommendMinimum;
    switch (game.versionNumber.minor ?? 0) {
      case <= 12:
        recommendMinimum = 1024;
      default:
        recommendMinimum = 2048;
    }
    if (maxMem < recommendMinimum) {
      messages.add(
          "可用内存过小，分配的内存为: $allocateMem，小于建议值: $recommendMinimum，这可能会导致游戏性能不佳。");
    }
    return messages;
  }

  /// 自动设置内存
  int setMaxMem() {
    if (game.setting.autoMemory) {
      final freeMem = sysinfo.freePhyMem.toMB();
      // 内存捉紧按空闲内存一半分配
      final persent = freeMem > 4096 ? 0.6 : 0.5;
      final allocate = freeMem * persent;
      // 限制上限 4096MB，如果是Mod版则上限 6144MB
      _allocateMem = min(allocate.toInt(), game.isModVersion ? 6144 : 4096);
      if (kDebugMode) {
        print(allocateMem);
      }
      return allocateMem;
    }
    return game.setting.maxMemory;
  }

  /// 自动设置 Java
  /// 数据来源：https://minecraft.fandom.com/zh/wiki/%E6%95%99%E7%A8%8B/%E6%9B%B4%E6%96%B0Java?variant=zh
  // FIXME: 可能不太精准
  Java? setJava() {
    if (game.setting.java == null) {
      final gameVersionNumber = game.versionNumber;
      final gameVersionMinor = gameVersionNumber.minor ?? 0;
      late final int minimumVersion; // 最低版本
      int? highestVersion; // 最高支持版本
      // int? recommendVersion; //推荐版本
      // 如果游戏版本大于等于 1.16
      switch (gameVersionMinor) {
        case <= 12:
          minimumVersion = 6;
          highestVersion = 8;
        case <= 16:
          minimumVersion = 8;
          highestVersion = 11;
        case <= 17:
          minimumVersion = 16;
        case <= 18:
          minimumVersion = 17;
        default:
          minimumVersion = 17;
      }
      // 自动搜寻与游戏版本最佳的 Java
      final targetList = <Java>[];
      for (var java in JavaUtil.set) {
        if (java.versionNumber.major >= minimumVersion &&
                highestVersion == null ||
            highestVersion != null &&
                java.versionNumber.major <= highestVersion) {
          targetList.add(java);
        }
      }
      if (targetList.isNotEmpty) {
        // 从低到高排序
        targetList.sort((a, b) => a.versionNumber.compareTo(b.versionNumber));
        java = targetList.first;
        if (kDebugMode) {
          print(targetList.map((e) => e.version));
        }
      }
      return java;
    }
    return game.setting.java;
  }

  Future<AccountLoginInfo> login(Account account) async =>
      loginInfo = await account.login();

  /// 获取可用的游戏资源
  Iterable<Library> getAllowedLibraries() => game.version.libraries.where(
      (lib) => lib is MavenLibrarie || lib is CommonLibrary && lib.isAllowed);

  /// 获取游戏匹配系统平台类型的 Natives 资源
  Iterable<Library> get requiredNativesLibraries =>
      allowedLibraries.whereType<NativesLibrary>();

  /// 检索游戏资源 返回游戏资源库中不存在的资源
  Stream<Library> get retrieveLibraries async* {
    _extractLibraries.clear();
    for (var lib in allowedLibraries) {
      if (lib is NativesLibrary) {
        _extractLibraries.add(lib);
      } else if (!await lib.exists(game.librariesPath)) {
        yield lib;
      }
    }
  }

  /// 生成随机本地存储的路径
  Future<String> get randomOutputPath async {
    final random = generateRandomString(8);
    return join((await getApplicationDocumentsDirectory()).path,
        "minecraft-${game.version.id}-natives-$random");
  }

  /// 获取游戏拼接资源 -cp 字符串
  String get argCp {
    const prefix = "-cp";
    final libraries = allowedLibraries;
    final librariesJars = [
      ...libraries.map((lib) => join(game.librariesPath, lib.jarPath)),
      game.clientPath
    ];
    return "$prefix ${librariesJars.join(';')}";
  }

  /// 获取启动参数
  Future<Iterable<String>> getLaunchArguments() async {
    if (loginInfo == null) {
      throw Exception("必须有登录信息");
    }
    final setting = game.setting;
    final version = game.version;
    // 命令行参数
    final args = [
      // 设置相关end
      GameArgument(
          "-Xmx${setting.autoMemory ? allocateMem : setting.maxMemory}M"),
      () {
        var arg = version.logging.client.argument;
        arg = arg.substring(0, arg.lastIndexOf('=') - 1);
        return GameArgument(arg, game.loggingPath);
      }(),
      GameArgument("-Dminecraft.client.jar", game.clientRelativePath),
      GameArgument(setting.jvmArgs),
      const GameArgument("-XX:HeapDumpPath",
          "MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump"),
      GameArgument("-Djava.library.path", game.nativeLibraryExtractPath),
      GameArgument("-Djna.tmpdir", game.nativeLibraryExtractPath),
      GameArgument("-Dorg.lwjgl.system.SharedLibraryExtractPath",
          game.nativeLibraryExtractPath),
      GameArgument("-Dio.netty.native.workdir", game.nativeLibraryExtractPath),
      const GameArgument("-Dminecraft.launcher.brand", appName),
      GameArgument("-Dminecraft.launcher.version", appInfo.version),
      GameArgument(argCp),
      GameArgument(version.mainClass),
      // 用户名
      GameArgument("--username ${loginInfo!.username}"),
      // version
      GameArgument("--version ${version.id}"),
      // 游戏路径
      GameArgument("--gameDir ${game.mainPath}"),
      // 资源文件路径
      GameArgument("--assetsDir ${game.assetsPath}"),
      // 资源索引版本
      if (version.assetIndex.id != null)
        GameArgument("--assetIndex ${version.assetIndex.id}"),
      // UUID
      GameArgument("--uuid ${loginInfo!.uuid.replaceAll('-', '')}"),
      // token
      if (loginInfo!.accessToken.isNotEmpty)
        GameArgument("--accessToken ${loginInfo!.accessToken}"),
      // 登录类型
      const GameArgument("--userType msa"),
      // 版本类型
      GameArgument('--versionType "$appName ${appInfo.version}"'),
      // 窗口长宽
      GameArgument("--width ${setting.width}"),
      GameArgument("--height ${setting.height}"),
    ];

    return args.map((arg) => arg.toString());
  }

  /// 主要用于启动测试
  Future<String> get launchCommand async {
    if (java == null) {
      throw Exception("启动游戏必须要安装 Java");
    }
    return "${java!.path} ${(await getLaunchArguments()).join(' ')}";
  }
}
