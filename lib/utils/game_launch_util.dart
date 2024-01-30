import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/main.dart';
import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/account_login_info.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/models/game/java.dart';
import 'package:one_launcher/models/game/data/library/common_library.dart';
import 'package:one_launcher/models/game/data/library/library.dart';
import 'package:one_launcher/models/game/data/library/maven_library.dart';
import 'package:one_launcher/models/game/data/library/natives_library.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:one_launcher/utils/random_string.dart';
import 'package:one_launcher/utils/sys_info/sys_info.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class GameLaunchUtil {
  GameLaunchUtil(this.game) {
    autoMem();
    autoJava();
  }

  final Game game;
  final List<NativesLibrary> _extractLibraries = [];
  final List<String> warningMessages = [];
  AccountLoginInfo? loginInfo;
  Iterable<Library>? _allowedLibraries;
  Iterable<Library> get allowedLibraries =>
      _allowedLibraries ??= getAllowedLibraries();

  late final int allocateMem;

  late final Java? java;

  /// 自动设置内存
  int autoMem() {
    if (game.setting.autoMemory) {
      final freeMem = sysinfo.freePhyMem.toMB();
      // 内存捉紧按空闲内存一半分配，否则四六开
      final persent = freeMem > 4096 ? 0.6 : 0.5;
      final allocate = freeMem * persent;
      // 限制下限 512MB, 上限 4096MB，如果是Mod版则上限 6144MB
      allocateMem =
          min(max(allocate.toInt(), 512), game.isModVersion ? 6144 : 4096);
      if (kDebugMode) {
        print(allocateMem);
      }
    } else {
      allocateMem = game.setting.maxMemory;
    }
    // 检查内存设置
    late final int recommendMinimum;
    switch (game.versionNumber?.minor ?? 0) {
      case <= 12:
        recommendMinimum = 1024;
      default:
        recommendMinimum = 2048;
    }
    if (allocateMem < recommendMinimum) {
      warningMessages.add(
          "可用内存过小，分配的内存为: ${allocateMem}MB，小于建议值: ${recommendMinimum}MB，这可能会导致游戏性能不佳甚至崩溃。");
    }
    return allocateMem;
  }

  /// 自动设置 Java
  /// 数据来源：https://minecraft.fandom.com/zh/wiki/%E6%95%99%E7%A8%8B/%E6%9B%B4%E6%96%B0Java?variant=zh
  Java? autoJava() {
    late final int minimumVersion; // 最低版本
    int? highestVersion; // 最高支持版本
    // int? recommendVersion; //推荐版本
    final gameVersionNumber = game.versionNumber;
    final gameVersionMinor = gameVersionNumber?.minor ?? 0;
    // 设置建议的Java版本
    // FIXME: 可能不太精准
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
        minimumVersion = 6;
    }
    if (game.setting.java == null) {
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
    } else {
      java = game.setting.java;
      // 检查选择的Java版本是否兼容
      final majorVersion = java!.versionNumber.major;
      if (majorVersion < minimumVersion) {
        warningMessages
            .add("选择的Java版本为：$majorVersion, 此游戏版本最低要求为：$minimumVersion。");
      }
    }
    // 如未找到Java
    if (java == null) {
      warningMessages.add("未找到安装的Java，如已安装请检查环境变量是否设置正确。");
    }
    return java;
  }

  Future<AccountLoginInfo> login(Account account) async =>
      loginInfo = await account.login();

  /// 获取可用的游戏资源
  Iterable<Library> getAllowedLibraries() => game.data.libraries.where(
      (lib) => lib is MavenLibrary || lib is CommonLibrary && lib.isAllowed);

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
        "minecraft-${game.data.id}-natives-$random");
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
    final version = game.data;
    // 命令行参数
    final args = [
      // 设置相关end
      GameArgument(
          "-Xmx${setting.autoMemory ? allocateMem : setting.maxMemory}M"),
      const GameArgument(
          "-Dfile.encoding=UTF-8 -Dsun.stdout.encoding=UTF-8 -Dsun.stderr.encoding=UTF-8 -Djava.rmi.server.useCodebaseOnly=true -Dcom.sun.jndi.rmi.object.trustURLCodebase=false -Dcom.sun.jndi.cosnaming.object.trustURLCodebase=false -Dlog4j2.formatMsgNoLookups=true"),
      if (version.logging != null)
        () {
          var arg = version.logging!.client.argument;
          arg = arg.substring(0, arg.lastIndexOf('=') - 1);
          return GameArgument(arg, game.loggingPath);
        }(),
      GameArgument("-Dminecraft.client.jar", game.clientRelativePath),
      GameArgument(setting.jvmArgs),
      const GameArgument(
          "-XX:-UseAdaptiveSizePolicy -XX:-OmitStackTraceInFastThrow -XX:-DontCompileHugeMethods -Dfml.ignoreInvalidMinecraftCertificates=true -Dfml.ignorePatchDiscrepancies=true"),
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
      GameArgument("--accessToken ${loginInfo!.accessToken}"),
      // 登录类型
      const GameArgument("--userType msa"),
      // 版本类型
      GameArgument('--versionType "$appName ${appInfo.version}"'),
      // 窗口长宽
      GameArgument("--width ${setting.width}"),
      GameArgument("--height ${setting.height}"),
      if (setting.fullScreen) const GameArgument("--fullscreen"),
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
