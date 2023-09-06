import 'dart:io';

import 'package:beacon/models/java.dart';

abstract final class JavaUtil {
  static Set<Java> set = {};

  static Future<void> init() async {
    set.clear();
    await pathOnEnvironment()
        .then((paths) => {for (final path in paths) set.add(Java(path))});
  }

  // static Java autoSelect(String version) {}

  static String getVersion(String path) {
    final regExp = RegExp(r'\\bin\\java\.exe$');
    final javaPath = path.replaceAll(regExp, '');
    final releaseFile = File('$javaPath/release');

    if (!releaseFile.existsSync()) {
      ProcessResult result = Process.runSync(path, ["-version"]);
      String version = result.stderr.split("\n")[0].split('"')[1];
      if (version.isEmpty) {
        return "Unknown";
      }
      return version;
    }

    var versionLine = releaseFile
        .readAsLinesSync()
        .firstWhere((line) => line.startsWith('JAVA_VERSION='));
    versionLine = versionLine.substring('JAVA_VERSION='.length);

    return versionLine.substring(1, versionLine.length - 1);
  }

  static Future<List<String>> pathOnEnvironment() async {
    final command = Platform.isWindows ? "where" : "which";
    var args = Platform.isWindows ? ["\$PATH:java"] : ["-a", "\$PATH", "java"];
    final variables = ["JAVA_HOME", "JRE_HOME"];
    final processResult = await Process.run(command, args, runInShell: true);
    final result = processResult.stdout.trim().split("\r\n");

    Future.forEach(variables, (element) async {
      final variable = Platform.environment[element];
      if (variable == null) return;
      final path = variable + (Platform.isWindows ? "\\bin" : "/bin");
      if (result.contains(
          path.trim() + (Platform.isWindows ? "\\java.exe" : "java"))) {
        return;
      }

      args = Platform.isWindows ? ['/R', path, "java"] : [element, "java"];
      final processResult = await Process.run(command, args, runInShell: true);
      if (processResult.stdout == "") return;
      result.add(processResult.stdout.trim());
    });
    return result;
  }
}
