import 'package:flutter/widgets.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/main.dart';
import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/account_login_info.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/models/game/version/librarie/common_librarie.dart';
import 'package:one_launcher/models/game/version/librarie/librarie.dart';
import 'package:one_launcher/models/game/version/librarie/maven_librarie.dart';
import 'package:one_launcher/models/game/version/librarie/natives_librarie.dart';
import 'package:one_launcher/utils/random_string.dart';
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

  // TODO: 测试
  /// 解压 [NativesLibrary]
  Future<void> extractNativesLibrary() async {
    final nativeFolderPath = game.librariesPath;
    final outputPath = game.nativeLibraryExtractPath;
    for (final lib in _extractLibraries) {
      lib.extract(nativeFolderPath, outputPath);
      debugPrint("extract: ${lib.name}");
    }
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
  Future<String> getStartupCommand() async {
    if (loginInfo == null) {
      throw ErrorDescription("必须有登录信息");
    }
    final setting = game.setting;
    final version = game.version;
    final java = setting.java;
    if (java == null) {
      throw ErrorDescription("启动游戏必须要安装Java");
    }
    // 命令行参数
    final args = [
      // 设置相关
      GameArgument(java.path),
      GameArgument("-Xmx${setting.maxMemory}M"),
      // 设置相关end
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

    return args.map((arg) => arg.toString()).join(' ');
  }
}
