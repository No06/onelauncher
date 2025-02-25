import 'dart:io';

import 'package:one_launcher/models/game/java.dart';
import 'package:one_launcher/utils/resolve_symbolic_link.dart';
import 'package:path/path.dart';

abstract final class JavaManager {
  static final Set<Java> _set = {};
  static Set<Java> get set => _set;

  static Future<void> init() async {
    _set.clear();
    final envPath = await getAllOnPathEnv();
    _set
      ..addAll(envPath ?? List.empty())
      ..addAll(await getAllOnJavaEnv());
  }

  static String get _searchBinName => Platform.isWindows ? "where" : "which";

  /// 从环境变量 PATH 中获取
  static Future<Iterable<Java>?> getAllOnPathEnv() async {
    final args =
        Platform.isWindows ? [r"$PATH:java"] : ["-a", r"$PATH", "java"];
    final processResult =
        await Process.run(_searchBinName, args, runInShell: true);
    final result = (processResult.stdout as String).trim();

    final splitStr = result.split("\r\n");
    if (splitStr.length == 1 && splitStr[0].isEmpty) {
      return null;
    }
    return splitStr.map((path) => Java.fromPath(resolveSymbolicLink(path)));
  }

  /// 从 Java 环境变量获取
  static Future<Set<Java>> getAllOnJavaEnv() async {
    final results = <Java>{};

    for (final env in ["JAVA_HOME", "JRE_HOME"]) {
      final variable = Platform.environment[env];
      if (variable == null) continue;

      final path = join(variable, "bin");
      final args = Platform.isWindows ? ['/R', path, "java"] : [path, "java"];
      final processResult =
          await Process.run(_searchBinName, args, runInShell: true);
      final stdout = processResult.stdout as String;
      if (stdout.isEmpty) continue;

      final javaPath = resolveSymbolicLink(stdout.trim());
      results.add(Java.fromPath(javaPath));
    }

    return results;
  }
}
