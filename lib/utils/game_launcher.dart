import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/account/account_login_info.dart';
import 'package:one_launcher/models/game/data/library/common_library.dart';
import 'package:one_launcher/models/game/data/library/library.dart';
import 'package:one_launcher/models/game/data/library/maven_library.dart';
import 'package:one_launcher/models/game/data/library/natives_library.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/models/game/java.dart';
import 'package:one_launcher/provider/game_setting_provider.dart';
import 'package:one_launcher/utils/extension/num_extension.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';
import 'package:one_launcher/utils/file/get_file_md5.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:one_launcher/utils/sysinfo/sysinfo.dart';
import 'package:path/path.dart';

class GameLauncher extends _GameLauncherInterface
    with
        _Checker,
        _GameArgumentParser,
        _LibraryArgumentParser,
        _JvmArgumentParser,
        _GameLaunchCommandGenerator,
        _Launcher {
  GameLauncher({
    required super.game,
    required super.globalSetting,
  });
}

abstract class _GameLauncherInterface {
  _GameLauncherInterface({
    required this.game,
    required this.globalSetting,
  });

  final Game game;
  final GameSetting globalSetting;

  late final _maxMemory = () {
    if (globalSetting.autoMemory) {
      final freeMem = Sysinfo().freePhyMem.toMB();
      // 内存捉紧按空闲内存一半分配，否则四六开
      final persent = freeMem > 4096 ? 0.6 : 0.5;
      final allocate = freeMem * persent;
      // 限制下限 512MB, 上限 4096MB，如果是Mod版则上限 6144MB
      return min(max(allocate.toInt(), 512), game.isModVersion ? 6144 : 4096);
    }
    return globalSetting.maxMemory;
  }();

  late final _java = () {
    final range = _calculateCompatibleJavaVersionRange();
    if (globalSetting.java == null) {
      Java? minimumVersionJava;
      for (final java in JavaManager.set) {
        if (range.contains(java.versionNumber.major)) {
          minimumVersionJava = java;
        }
      }
      return minimumVersionJava;
    }
    return globalSetting.java;
  }();

  _JavaVersionRange _calculateCompatibleJavaVersionRange() {
    var minimumVersion = game.data.javaVersion?.majorVersion; // 最低版本
    int? highestVersion; // 最高支持版本
    // int? recommendVersion; //推荐版本
    final gameMinorVersion = game.versionNumber?.minor ?? 0;
    // Calculate the minimum version of Java required for the game
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
    return _JavaVersionRange(minimum: minimumVersion, maximum: highestVersion);
  }

  List<String> checkSettings();

  Future<void> launch(AccountLoginInfo loginInfo);

  void cancelLaunch();

  Future<_LibraryRetrieveResult> get retrieveLibraries;

  Future<void> extractUnavaliableNativesLibraries();
}

mixin _Checker on _GameLauncherInterface {
  var _hasChecked = false;

  /// Check the game settings before launching
  @override
  List<String> checkSettings() {
    memCheck() {
      int recommendMinimum;
      switch (game.versionNumber?.minor ?? 0) {
        case <= 12:
          recommendMinimum = 1024;
        default:
          recommendMinimum = 2048;
      }
      if (_maxMemory < recommendMinimum) {
        return "可用内存过小，分配的内存为: ${_maxMemory}MB，小于建议值: ${recommendMinimum}MB，这可能会导致游戏性能不佳甚至崩溃。";
      }
    }

    javaCheck() {
      if (_java == null) {
        return "未找到安装的Java，如已安装请检查环境变量是否设置正确。";
      }
      final range = _calculateCompatibleJavaVersionRange();
      final minimumVersion = range.minimum;
      final majorVersion = _java.versionNumber.major;
      if (majorVersion < minimumVersion) {
        return "选择的Java版本为：$majorVersion, 此游戏版本最低要求为：$minimumVersion。";
      }
    }

    _hasChecked = true;
    final message = [
      memCheck(),
      javaCheck(),
    ]..removeWhere((element) => element == null);
    return message.cast<String>();
  }
}

mixin _Launcher
    on _GameLauncherInterface, _Checker, _GameLaunchCommandGenerator {
  Process? _process;

  /// Launch the game after checking the settings
  /// ```dart
  /// final launcher = GameLauncher(game: game, globalSetting: globalSetting);
  /// final message = launcher.checkSettings();
  /// if (message.isNotEmpty) {
  /// // Show the message to the user
  /// }
  /// launcher.retrieveLibraries
  /// launcher.launch();
  /// ```
  @override
  Future<void> launch(AccountLoginInfo loginInfo) async {
    if (kDebugMode) {
      assert(
        _hasChecked,
        "You must check the settings before launching the game.",
      );
    }

    final completer = Completer<void>();
    final command = await _generateGameLaunchCommand(loginInfo);
    final runInShell = (game.versionNumber?.minor ?? 9) <= 8;
    _process = await Process.start(
      command,
      [],
      workingDirectory: game.mainPath,
      runInShell: runInShell,
    );
    final errSubscription =
        _process!.stderr.transform(utf8.decoder).listen((data) {
      data.printError("Process error message");
      if (data.isNotEmpty) {
        try {
          if (!completer.isCompleted) completer.completeError(data);
        } catch (e) {
          e.printError();
        }
      }
    });
    final subscription =
        _process!.stdout.transform(utf8.decoder).listen((data) {
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

    unawaited(
      _process!.exitCode.then((value) {
        subscription.cancel();
        errSubscription.cancel();
      }),
    );

    return completer.future;
  }

  @override
  void cancelLaunch() {
    _process?.kill();
  }
}

mixin _JvmArgumentParser on _GameLauncherInterface, _LibraryArgumentParser {
  // example: -cp "lib/*;client.jar"
  String get _classPathArgs => [
        ..._avaliableLibraries
            .where((element) => element is! NativesLibrary)
            .map((lib) => join(game.librariesPath, lib.jarPath)),
        game.clientPath,
      ].join(';');

  String get _jvmArgs {
    /// 一个映射，用来存储变量名和对应的值
    final jvmArgsMap = <String, String>{
      "natives_directory": game.nativesPath,
      "launcher_name": kAppName,
      "launcher_version": "114514",
      "classpath": _classPathArgs,
      "clientpath": game.clientPath,
    };
    if (game.data.arguments == null) {
      return _replaceVariable(
        r'-Djava.library.path=${natives_directory} -cp ${classpath}',
        jvmArgsMap,
      );
    }
    return _replaceVariables(game.data.arguments?.jvmFilterString, jvmArgsMap)
        .map(_addQuote)
        .join(' ');
  }
}

mixin _GameArgumentParser on _GameLauncherInterface {
  String _gameArgs(AccountLoginInfo loginInfo) {
    final gameArgsMap = <String, String?>{
      "auth_player_name": loginInfo.username,
      "version_name": game.data.id,
      "game_directory": game.mainPath,
      "assets_root": game.assetsPath,
      "assets_index_name": game.data.assetIndex?.id,
      "auth_uuid": loginInfo.uuid,
      "auth_access_token": loginInfo.accessToken,
      "user_type": "msa",
      "version_type": '"$kAppName"',
      "user_properties": "{}",
    };

    final arguments = game.data.arguments?.gameFilterString;
    if (arguments != null) {
      return [
        ..._replaceVariables(
          game.data.arguments?.gameFilterString,
          gameArgsMap,
        ),
        "--width ${globalSetting.width}",
        "--height ${globalSetting.height}",
        if (globalSetting.fullScreen) "--fullscreen",
      ].join(' ');
    }
    // 低版本
    final minecraftArguments = game.data.minecraftArguments;
    if (minecraftArguments == null) {
      throw Exception("未在游戏中找到JVM参数");
    }

    return _replaceVariable(minecraftArguments, gameArgsMap);
  }

  String? get _loggingArg {
    var arg = game.data.logging?.client?.argument;
    if (arg == null || game.loggingPath == null) return null;

    arg = arg.substring(0, arg.lastIndexOf('=') - 1);
    return GameArgument(arg, _addQuote(game.loggingPath!)).toString();
  }
}

mixin _LibraryArgumentParser on _GameLauncherInterface {
  Iterable<Library> get _avaliableLibraries => game.data.libraries.where(
        (lib) => lib is MavenLibrary || lib is CommonLibrary && lib.isAllowed,
      );

  Iterable<NativesLibrary> get _nativesLibraries =>
      _avaliableLibraries.whereType<NativesLibrary>();

  @override
  Future<_LibraryRetrieveResult> get retrieveLibraries async {
    final nativesLibraries = <NativesLibrary>[];
    final nonExistenceLibraries = <Library>[];
    for (final lib in _avaliableLibraries) {
      if (lib is NativesLibrary) {
        nativesLibraries.add(lib);
      } else if (!lib.existInGame(game.librariesPath)) {
        nonExistenceLibraries.add(lib);
      }
    }
    return _LibraryRetrieveResult(
      nativesLibraries: nativesLibraries,
      nonExistenceLibraries: nonExistenceLibraries,
    );
  }

  Future<Iterable<NativesLibrary>> get _unavaliableNativesLibraries async {
    final outputDirectory = Directory(game.nativesPath);
    if (!outputDirectory.existsSync()) return _nativesLibraries;

    /// Get the list of files in the output directory
    /// and create a map of file names to file objects
    final outputFiles = outputDirectory.listSync();
    if (outputFiles.isEmpty) return _nativesLibraries;

    final outputFilesNameMap = Map.fromIterables(
      outputFiles.map((e) => e.path.substring(e.path.lastIndexOf('/') + 1)),
      outputFiles,
    );

    final nativesArchives = Map.fromIterables(
      _nativesLibraries,
      _nativesLibraries.map(
        (e) => ZipDecoder().decodeBytes(
          File(e.getFullPath(game.librariesPath)).readAsBytesSync(),
        ),
      ),
    );

    final unavaliableNativesLibraries = <NativesLibrary>[];
    for (final nativesArchive in nativesArchives.entries) {
      final nativesLibrary = nativesArchive.key;
      final archive = nativesArchive.value;

      for (final file in archive.files) {
        // Check if the file exists in the output directory
        final filePath = outputFilesNameMap[file.name]?.path;
        final fileExists = filePath != null;
        if (!fileExists) {
          unavaliableNativesLibraries.add(nativesLibrary);
          break;
        }
        // Check if the file has been modified
        final sourceMd5 = md5.convert(file.content as Uint8List);
        final targetMd5 = await getFileMd5(filePath);
        final fileModified = sourceMd5 != targetMd5;
        if (fileModified) {
          unavaliableNativesLibraries.add(nativesLibrary);
          break;
        }
      }
    }
    return unavaliableNativesLibraries;
  }

  @override
  Future<void> extractUnavaliableNativesLibraries() async {
    final unavaliableNativesLibraries = await _unavaliableNativesLibraries;
    for (final nativesLibrary in unavaliableNativesLibraries) {
      await nativesLibrary.extract(game.librariesPath, game.nativesPath);
    }
  }
}

mixin _GameLaunchCommandGenerator
    on _GameLauncherInterface, _GameArgumentParser, _JvmArgumentParser {
  Future<String> _generateGameLaunchCommand(AccountLoginInfo loginInfo) async {
    if (_java == null) {
      throw Exception("Cannot find the Java executable.");
    }
    return "${_java.path} ${(await _generateGameArguments(loginInfo)).join(' ')}";
  }

  Future<Iterable<String>> _generateGameArguments(
    AccountLoginInfo loginInfo,
  ) async {
    final setting = globalSetting;
    final version = game.data;
    // 命令行参数
    final args = [
      // 设置相关end
      GameArgument(
        "-Xmx${setting.autoMemory ? _maxMemory : setting.maxMemory}M",
      ),
      const GameArgument(
        "-Dfile.encoding=UTF-8 -Dsun.stdout.encoding=UTF-8 -Dsun.stderr.encoding=UTF-8 -Djava.rmi.server.useCodebaseOnly=true -Dcom.sun.jndi.rmi.object.trustURLCodebase=false -Dcom.sun.jndi.cosnaming.object.trustURLCodebase=false -Dlog4j2.formatMsgNoLookups=true",
      ),
      if (game.data.logging != null) GameArgument(_loggingArg!),
      GameArgument(
        "-Dminecraft.client.jar",
        _addQuote(game.clientRelativePath),
      ),
      GameArgument(setting.adaptiveJvmArgs),
      const GameArgument(
        "-XX:-UseAdaptiveSizePolicy -XX:-OmitStackTraceInFastThrow -XX:-DontCompileHugeMethods -Dfml.ignoreInvalidMinecraftCertificates=true -Dfml.ignorePatchDiscrepancies=true",
      ),
      if (Platform.isWindows)
        const GameArgument(
          "-XX:HeapDumpPath",
          "MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump",
        ),
      // JVM 启动参数
      GameArgument(_jvmArgs),
      if (version.mainClass != null) GameArgument(version.mainClass!),
      // 游戏参数
      GameArgument(_gameArgs(loginInfo)),
    ];

    return args.map((arg) => arg.toString());
  }
}

class _JavaVersionRange {
  _JavaVersionRange({
    required this.minimum,
    required this.maximum,
  });

  final int minimum;
  final int? maximum;

  bool contains(int version) =>
      version >= minimum && (maximum == null || version <= maximum!);
}

class _LibraryRetrieveResult {
  const _LibraryRetrieveResult({
    required this.nativesLibraries,
    required this.nonExistenceLibraries,
  });

  final List<NativesLibrary> nativesLibraries;
  final List<Library> nonExistenceLibraries;
}

String _addQuote(String string) => '"$string"';

/// 批量替换参数中 ${} 的内容
List<String> _replaceVariables(
  Iterable<String>? input,
  Map<String, String?> valueMap,
) {
  if (input == null) return [];
  return input.map((arg) => _replaceVariable(arg, valueMap, true)).toList();
}

/// 替换参数中 ${} 的内容
/// [replaceFirst] 为 true 时只匹配一次
String _replaceVariable(
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
