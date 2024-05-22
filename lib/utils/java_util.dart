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
    _set.addAll(envPath);
    _set.addAll(await getAllOnJavaEnv());
  }

  static get _searchBinName => Platform.isWindows ? "where" : "which";

  /// 从环境变量 PATH 中获取
  static Future<List<Java>> getAllOnPathEnv() async {
    final args =
        Platform.isWindows ? ["\$PATH:java"] : ["-a", "\$PATH", "java"];
    final processResult =
        await Process.run(_searchBinName, args, runInShell: true);
    final result = (processResult.stdout as String).trim();

    var objects = <Java>[];
    var start = 0;

    for (int i = 0; i <= result.length;) {
      // 检查是否到达字符串末尾或者遇到换行符
      if (i == result.length || (result[i] == '\r' && result[i + 1] == '\n')) {
        // 从上一个起点到当前位置的子字符串
        String path = result.substring(start, i);
        objects.add(Java(path));
        // 更新起点为下一行的开始
        start = i + 2;
        // 跳过换行符
        i++;
      }
    }

    return objects;
  }

  /// 从 Java 环境变量获取
  static Future<Set<Java>> getAllOnJavaEnv() async {
    final results = <Java>{};

    for (var env in ["JAVA_HOME", "JRE_HOME"]) {
      final variable = Platform.environment[env];
      if (variable == null) continue;

      final path = join(variable, "bin");
      final args = Platform.isWindows ? ['/R', path, "java"] : [path, "java"];
      final processResult =
          await Process.run(_searchBinName, args, runInShell: true);
      final stdout = processResult.stdout;
      if (stdout == "") continue;

      final javaPath = resolveSymbolicLink(stdout.trim());
      results.add(Java(javaPath));
    }

    return results;
  }
}
