import 'dart:convert';
import 'dart:io';

import 'package:one_launcher/consts.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';

import '../game/game.dart';

part 'game_path_config.g.dart';

/// 游戏路径
/// 路径应传入如: /home/onelauncher/.minecraft
@JsonSerializable()
class GamePath extends ChangeNotifier {
  GamePath({String? name, String? path})
      : _name = ValueNotifier(name ?? ""),
        _path = ValueNotifier(path ?? ""),
        super() {
    _name.addListener(notifyListeners);
    _path.addListener(notifyListeners);
  }

  ValueNotifier<String> _name;
  ValueNotifier<String> _path;

  ValueNotifier<String> get nameNotifier => _name;
  String get name => _name.value;
  set name(String newVal) => _name.value = newVal;

  ValueNotifier<String> get pathNotifier => _path;
  String get path => _path.value;
  set path(String newVal) => _path.value = newVal;

  final _availableGames = <Game>[];
  List<Game> get availableGames => _availableGames;

  /// 从 [path] 路径下的 versions 文件夹中搜索游戏
  Future<List<Game>> get gamesOnVersion async {
    var results = <Game>[];
    var directory = Directory(join(path, "versions"));
    // 如果文件夹不存在则直接返回空结果
    if (!directory.existsSync()) return results;

    await for (var dir in directory.list(followLinks: false)) {
      final json = join(dir.path, "${basename(dir.path)}.json");
      // 如果该路径是文件夹或者文件
      if (await Directory(join(path, dir.path)).exists() &&
          await File(json).exists()) {
        var gameConfig = File(join(dir.path, kGameConfigName));
        // 如果存在启动器生成的单独配置文件
        if (await gameConfig.exists()) {
          results.add(
            Game.fromJson(
              _path.value,
              dir.path.substring(_path.value.length),
              jsonDecode(gameConfig.readAsStringSync()),
            ),
          );
        } else {
          results.add(Game(
            _path.value,
            dir.path.substring(_path.value.length + 1),
          ));
        }
      }
    }
    return results;
  }

  factory GamePath.fromJson(Map<String, dynamic> json) =>
      _$GamePathFromJson(json);

  Map<String, dynamic> toJson() => _$GamePathToJson(this);

  @override
  int get hashCode {
    return path.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is! GamePath) return false;
    return path == other.path && other._name == _name;
  }
}
