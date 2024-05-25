import 'dart:convert';
import 'dart:io';

import 'package:get/utils.dart';
import 'package:one_launcher/consts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:path/path.dart';

import 'game.dart';

part 'game_path.g.dart';

/// 游戏路径
/// 路径应传入如: /home/onelauncher/.minecraft
@JsonSerializable()
class GamePath {
  const GamePath({required this.name, required this.path});

  final String name;
  final String path;

  /// 从 [path] 路径下的 versions 文件夹中搜索游戏
  Stream<Game> get games async* {
    var directory = Directory(join(path, "versions"));
    // 如果文件夹不存在则直接返回空结果
    if (!directory.existsSync()) return;

    await for (var dir in directory.list(followLinks: false)) {
      final json = join(dir.path, "${basename(dir.path)}.json");
      // 如果该文件夹存在且存在相同命名的json文件
      if (await Directory(join(path, dir.path)).exists() &&
          await File(json).exists()) {
        var gameConfig = File(join(dir.path, kGameConfigName));
        final librariesPath = path;
        final versionPath = dir.path.substring(path.length + 1);
        // 如果存在启动器生成的单独配置文件
        try {
          if (await gameConfig.exists()) {
            yield Game.fromJson(
              librariesPath,
              versionPath,
              jsonDecode(gameConfig.readAsStringSync()),
            );
          } else {
            yield Game(librariesPath, versionPath);
          }
          // 如有异常则跳过
        } catch (e) {
          e.printError(info: "path: ${dir.path}");
        }
      }
    }
  }

  factory GamePath.fromJson(JsonMap json) => _$GamePathFromJson(json);

  JsonMap toJson() => _$GamePathToJson(this);

  @override
  int get hashCode {
    return path.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is! GamePath) return false;
    return path == other.path;
  }
}
