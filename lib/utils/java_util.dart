import 'dart:io';

import 'package:one_launcher/models/java.dart';
import 'package:path/path.dart';

final kJavaBinName = Platform.isWindows ? "java.exe" : "java";
const _kJavaVariables = ["JAVA_HOME", "JRE_HOME"];
final _kPlatformSearchCommand = Platform.isWindows ? "where" : "which";

abstract final class JavaUtil {
  static final Set<Java> _set = {};
  static Set<Java> get set => _set;

  static Future<void> init() async {
    _set.clear();
    final envPath = await getOnEnvPath();
    if (envPath != null) _set.addAll(envPath);
    _set.addAll(await getOnEnvJava());
  }

  static Future<Iterable<Java>?> getOnEnvPath() async {
    final args =
        Platform.isWindows ? ["\$PATH:java"] : ["-a", "\$PATH", "java"];
    final processResult =
        await Process.run(_kPlatformSearchCommand, args, runInShell: true);
    final stdout = (processResult.stdout as String).trim();
    final splitStr = stdout.split("\r\n");
    if (splitStr.length == 1 && splitStr[0].isEmpty) {
      return null;
    }
    return splitStr.map((path) => Java(_resolveSymbolicLink(path)));
  }

  static Future<Set<Java>> getOnEnvJava() async {
    final results = <Java>{};
    for (var env in _kJavaVariables) {
      final variable = Platform.environment[env] ?? "";
      if (variable == "") continue;

      final path = join(variable, "bin");
      final args = Platform.isWindows ? ['/R', path, "java"] : [path, "java"];
      final processResult =
          await Process.run(_kPlatformSearchCommand, args, runInShell: true);
      final stdout = processResult.stdout;
      if (stdout == "") continue;

      final javaPath = _resolveSymbolicLink(stdout.trim());
      results.add(Java(javaPath));
    }
    return results;
  }

  static String _resolveSymbolicLink(String path) =>
      FileSystemEntity.isLinkSync(path)
          ? Link(path).resolveSymbolicLinksSync()
          : path;
}
