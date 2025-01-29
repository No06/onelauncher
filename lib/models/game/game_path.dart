import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';
import 'package:path/path.dart';

part 'game_path.g.dart';

/// 游戏路径
/// 路径应传入如: /home/onelauncher/.minecraft
@immutable
@JsonSerializable()
class GamePath {
  const GamePath({required this.name, required this.path});

  factory GamePath.fromJson(JsonMap json) => _$GamePathFromJson(json);

  final String name;
  final String path;

  /// 从 [path] 路径下的 versions 文件夹中搜索游戏
  Stream<Game> get games async* {
    final directory = Directory(join(path, "versions"));
    // 如果文件夹不存在则直接返回空结果
    if (!directory.existsSync()) return;

    await for (final dir in directory.list(followLinks: false)) {
      final json = join(dir.path, "${basename(dir.path)}.json");
      // 如果该文件夹存在且存在相同命名的json文件
      if (Directory(join(path, dir.path)).existsSync() &&
          File(json).existsSync()) {
        final librariesPath = path;
        final versionPath = dir.path.substring(path.length + 1);
        // 如果存在启动器生成的单独配置文件
        try {
          yield Game(librariesPath, versionPath);
          // 如有异常则跳过
        } catch (e) {
          e.printError(dir.path);
        }
      }
    }
  }

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
