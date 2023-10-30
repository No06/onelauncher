import 'dart:convert';
import 'dart:io';

import 'package:one_launcher/consts.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';

import 'game/game.dart';

part 'game_path_config.g.dart';

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

  Future<List<Game>> get gamesOnVersion async {
    var results = <Game>[];
    var directory = Directory(join(path, "versions"));
    if (!directory.existsSync()) return results;
    var stream = directory.list(followLinks: false);
    await for (var dir in stream) {
      final json = join(dir.path, "${basename(dir.path)}.json");
      if (await Directory(join(path, dir.path)).exists() &&
          await File(json).exists()) {
        var gameConfig = File(join(dir.path, kGameConfigName));
        if (gameConfig.existsSync()) {
          results.add(
            Game.fromJson(
              _path.value,
              dir.path.substring(_path.value.length),
              jsonDecode(gameConfig.readAsStringSync()),
            ),
          );
        } else {
          results.add(
              Game(_path.value, dir.path.substring(_path.value.length + 1)));
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
