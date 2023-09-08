import 'dart:io';

import 'package:beacon/models/java.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

const _kJavaVersionLine = "JAVA_VERSION=";
const _kJavaVariables = ["JAVA_HOME", "JRE_HOME"];
final _kPlatformSearchCommand = Platform.isWindows ? "where" : "which";
final _kPlatformSearchVariableArgs =
    Platform.isWindows ? ["\$PATH:java"] : ["-a", "\$PATH", "java"];

abstract final class JavaUtil {
  static Set<Java> set = {};

  static Future<void> init() async {
    set.clear();
    set.assignAll(await getByEnvironment());
  }

  // static Java autoSelect(String version) {}

  static String getVersionByRun(String path) {
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
        .firstWhere((line) => line.startsWith(_kJavaVersionLine));
    versionLine = versionLine.substring(_kJavaVersionLine.length);

    return versionLine.substring(1, versionLine.length - 1);
  }

  static Future<Set<Java>> getByEnvironment() async {
    final results = <Java>{};
    final processResult = await Process.run(
      _kPlatformSearchCommand,
      _kPlatformSearchVariableArgs,
      runInShell: true,
    );
    results.addAll((processResult.stdout as String)
        .trim()
        .split("\r\n")
        .map((e) => Java(e)));

    await Future.forEach(_kJavaVariables, (element) async {
      final variable = Platform.environment[element];
      if (variable == null) return;

      final path = join(variable, "bin");
      final args = Platform.isWindows ? ['/R', path, "java"] : [path, "java"];
      final processResult =
          await Process.run(_kPlatformSearchCommand, args, runInShell: true);
      if (processResult.stdout == "") return;
      results.add(Java(processResult.stdout.trim()));
    });
    return results;
  }
}
