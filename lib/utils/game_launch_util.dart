import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/account_login_info.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/models/game/java.dart';
import 'package:one_launcher/models/game/data/library/common_library.dart';
import 'package:one_launcher/models/game/data/library/library.dart';
import 'package:one_launcher/models/game/data/library/maven_library.dart';
import 'package:one_launcher/models/game/data/library/natives_library.dart';
import 'package:one_launcher/provider/game_setting_provider.dart';
import 'package:one_launcher/utils/extension/list_extension.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';
import 'package:one_launcher/utils/file/get_file_md5.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:one_launcher/utils/platform/sys_info/sys_info.dart';
import 'package:path/path.dart';

class GameLaunchUtil {
  GameLaunchUtil(this.game, this.globarSetting) {
    autoMem();
    autoJava();
  }

  late final int allocateMem;
  final completer = Completer();

  final Game game;
  final GameSettingState globarSetting;
  late final Java? java;
  AccountLoginInfo? loginInfo;

  Process? process;
  StreamSubscription? errSubscription;
  StreamSubscription? subscription;
  final List<String> warningMessages = [];

  Iterable<Library>? _allowedLibraries;
  final List<NativesLibrary> _nativesLibraries = [];

  Iterable<Library> get allowedLibraries =>
      _allowedLibraries ??= getAllowedLibraries();

  /// 取消程序监听
  void cancel() async {
    subscription?.cancel();
    errSubscription?.cancel();
  }

  void killProcess() => process?.kill();

  bool get runInShell => (game.versionNumber?.minor ?? 9) <= 8;

  /// 启动游戏
  Future<void> launchGame() async {
    Future(() async => await launchCommand
      ..printInfo());

    process = await Process.start(
      await launchCommand,
      [],
      workingDirectory: game.mainPath,
      runInShell: runInShell,
    );

    // 监听子进程的错误
    errSubscription = process!.stderr.transform(utf8.decoder).listen((data) {
      data.printError("Process error message");
      if (data.isNotEmpty) {
        try {
          if (!completer.isCompleted) completer.completeError(data);
        } catch (e) {
          e.printError();
        }
      }
    });

    // 监听子进程
    subscription = process!.stdout.transform(utf8.decoder).listen((data) {
      data.printInfo("Process message");
      try {
        if (data.startsWith("Setting user", 33) ||
            data.startsWith("Minecraft reloaded", 33) ||
            data.startsWith("Stopping!", 33)) {
          completer.complete();
        }
      } catch (e) {
        e.printError();
      }
    });
    return await completer.future;
  }

  /// 自动设置内存
  int autoMem() {
    if (globarSetting.autoMemory) {
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
      allocateMem = globarSetting.maxMemory;
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
    int? minimumVersion = game.data.javaVersion?.majorVersion; // 最低版本
    int? highestVersion; // 最高支持版本
    // int? recommendVersion; //推荐版本
    final gameMinorVersion = game.versionNumber?.minor ?? 0;
    // 设置建议的Java版本
    // FIXME: 可能不太精准
    if (minimumVersion == null) {
      switch (gameMinorVersion) {
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
    }
    if (globarSetting.java == null) {
      // 自动搜寻与游戏版本最佳的 Java
      final targetList = <Java>[];
      for (var java in JavaManager.set) {
        if (java.versionNumber.major >= minimumVersion &&
                highestVersion == null ||
            highestVersion != null &&
                java.versionNumber.major <= highestVersion) {
          targetList.add(java);
        }
      }
      if (targetList.isNotEmpty) {
        // 从低到高排序
        targetList.sort((a, b) => (a.versionNumber).compareTo(b.versionNumber));
        java = targetList.first;
        if (kDebugMode) {
          print(targetList.map((e) => e.version));
        }
      }
      return java;
    } else {
      java = globarSetting.java;
      // 检查选择的Java版本是否兼容
      final majorVersion = (java!.versionNumber).major;
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
    for (var lib in allowedLibraries) {
      if (lib is NativesLibrary) {
        _nativesLibraries.add(lib);
      } else if (!await lib.exists(game.librariesPath)) {
        if (kDebugMode) {
          lib.getPath(game.librariesPath).printInfo('');
        }
        yield lib;
      }
    }
  }

  /// 解压natives资源
  Future<void> extractNativesLibraries() async {
    final outputDirectory = Directory(game.nativesPath);
    if (!await outputDirectory.exists()) await outputDirectory.create();

    final targetFiles = outputDirectory.listSync();
    final targerFilesMap = Map.fromIterables(
      targetFiles.map((e) => e.path.split("/").last),
      targetFiles,
    );
    if (await outputDirectory.exists() && targetFiles.isNotEmpty) {
      final archives = _nativesLibraries.map(
        (e) => ZipDecoder().decodeBytes(
          File(e.getNativePath(game.librariesPath)).readAsBytesSync(),
        ),
      );
      final files = [
        for (final archive in archives)
          for (final file in archive.files) file
      ];
      // 使用MD5比对
      final needExtract = await Future(() async {
        for (var i = 0; i < files.length; i++) {
          final sourceFile = files.elementAt(i);
          final sourceFileMd5 = md5.convert(sourceFile.content as Uint8List);
          final targetFilePath = targerFilesMap[sourceFile.name]?.path;
          if (targetFilePath == null) {
            return true;
          }
          final targetFileMd5 = await getFileMd5(targetFilePath);
          if (sourceFileMd5 != targetFileMd5) {
            return true;
          }
        }
        return false;
      });

      if (needExtract) {
        outputDirectory.deleteSync(recursive: true);
      }
    }
    await Future.wait(_nativesLibraries
        .map((e) => e.extract(game.librariesPath, game.nativesPath)));
  }

  /// 为字符串添加双引号
  String addQuote(String string) => "\"$string\"";

  /// 获取游戏拼接资源 -cp 字符串
  String get classPathsArgs => [
        ...allowedLibraries
            .where((element) => element is! NativesLibrary)
            .map((lib) => join(game.librariesPath, lib.jarPath)),
        game.clientPath
      ].join(';');

  /// 批量替换参数中 ${} 的内容
  List<String> replaceVariables(
    Iterable<String>? input,
    Map<String, String?> valueMap,
  ) {
    if (input == null) return [];
    return input.map((arg) => replaceVariable(arg, valueMap, true)).toList();
  }

  /// 替换参数中 ${} 的内容
  /// [replaceFirst] 为 [true] 时只匹配一次
  String replaceVariable(
    String value,
    Map<String, String?> valueMap, [
    bool replaceFirst = false,
  ]) {
    // 正则用于解析出 ${xxx} 内容
    final argumentRegex = RegExp(r"\${(\w+)}");
    String replace(Match match) => valueMap[match[1]] ?? match[0]!;
    return replaceFirst
        ? value.replaceFirstMapped(argumentRegex, replace)
        : value.replaceAllMapped(argumentRegex, replace);
  }

  /// 获取游戏启动项
  String get gameArgs {
    assert(loginInfo != null);

    /// 一个映射，用来存储变量名和对应的值
    final gameArgsMap = <String, String?>{
      "auth_player_name": loginInfo!.username,
      "version_name": game.data.id,
      "game_directory": game.mainPath,
      "assets_root": game.assetsPath,
      "assets_index_name": game.data.assetIndex?.id,
      "auth_uuid": loginInfo!.uuid,
      "auth_access_token": loginInfo!.accessToken,
      "user_type": "msa",
      "version_type": '"$kAppName"',
      "user_properties": "{}",
    };
    dynamic arguments = game.data.arguments?.gameFilterString;
    // 高版本
    if (arguments != null) {
      return (replaceVariables(
              game.data.arguments?.gameFilterString, gameArgsMap)
            ..add("--width ${globarSetting.width}")
            ..add("--height ${globarSetting.height}")
            ..addIf(globarSetting.fullScreen, "--fullscreen"))
          .join(' ');
    }
    // 低版本
    arguments = game.data.minecraftArguments;
    if (arguments == null) {
      throw Exception("未在游戏中找到JVM参数");
    }

    return replaceVariable(arguments, gameArgsMap);
  }

  /// 获取JVM参数
  String get jvmArgs {
    /// 一个映射，用来存储变量名和对应的值
    /// TODO: 待补充
    final jvmArgsMap = <String, String>{
      "natives_directory": game.nativesPath,
      "launcher_name": kAppName,
      "launcher_version": "114514",
      "classpath": classPathsArgs,
      "clientpath": game.clientPath,
    };
    if (game.data.arguments == null) {
      return replaceVariable(
        '-Djava.library.path=\${natives_directory} -cp \${classpath}',
        jvmArgsMap,
      );
    }
    return replaceVariables(game.data.arguments?.jvmFilterString, jvmArgsMap)
        .map((e) => addQuote(e))
        .join(' ');
  }

  /// 获取 logging 启动参数
  /// 根据 [Game.loggingPath] 判断然后生成
  String? get loggingArg {
    var arg = game.data.logging?.client?.argument;
    if (arg == null || game.loggingPath == null) return null;

    arg = arg.substring(0, arg.lastIndexOf('=') - 1);
    return GameArgument(arg, addQuote(game.loggingPath!)).toString();
  }

  /// 获取启动参数
  Future<Iterable<String>> getLaunchArguments() async {
    final setting = globarSetting;
    final version = game.data;
    // 命令行参数
    final args = [
      // 设置相关end
      GameArgument(
          "-Xmx${setting.autoMemory ? allocateMem : setting.maxMemory}M"),
      const GameArgument(
          "-Dfile.encoding=UTF-8 -Dsun.stdout.encoding=UTF-8 -Dsun.stderr.encoding=UTF-8 -Djava.rmi.server.useCodebaseOnly=true -Dcom.sun.jndi.rmi.object.trustURLCodebase=false -Dcom.sun.jndi.cosnaming.object.trustURLCodebase=false -Dlog4j2.formatMsgNoLookups=true"),
      if (game.data.logging != null) GameArgument(loggingArg!),
      GameArgument("-Dminecraft.client.jar", addQuote(game.clientRelativePath)),
      GameArgument(setting.adaptiveJvmArgs),
      const GameArgument(
          "-XX:-UseAdaptiveSizePolicy -XX:-OmitStackTraceInFastThrow -XX:-DontCompileHugeMethods -Dfml.ignoreInvalidMinecraftCertificates=true -Dfml.ignorePatchDiscrepancies=true"),
      if (Platform.isWindows)
        const GameArgument("-XX:HeapDumpPath",
            "MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump"),
      // JVM 启动参数
      GameArgument(jvmArgs),
      if (version.mainClass != null) GameArgument(version.mainClass!),
      // 游戏参数
      GameArgument(gameArgs),
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
