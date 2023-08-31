import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as p;

import 'game.dart';

part 'path.g.dart';

@JsonSerializable()
class GamePath {
  GamePath({this.name = "", this.path = ""});

  final String name;
  final String path;

  final _availableGames = <Game>[];
  List<Game> get availableGames => _availableGames;

  static final _paths = [
    GamePath(
      name: "启动器目录",
      path: p.join(File(Platform.resolvedExecutable).parent.path, '.minecraft'),
    ),
    // TODO: Linux & Macos 官方启动器目录
    GamePath(
      name: "官方启动器目录",
      path: p.join(
          Platform.environment['APPDATA'] ??
              "C:\\Users\\${Platform.environment['USERNAME']}\\AppData",
          'Roadming',
          '.minecraft'),
    ),
  ].obs;
  // ignore: invalid_use_of_protected_member
  static List<GamePath> get paths => _paths.value;

  static bool addPath(String name, String path) {
    if (Directory(path).existsSync()) {
      paths.add(GamePath.fromJson({name: name, path: path}));
      return true;
    }
    return false;
  }

  Future<void> searchOnVersions() async {
    _availableGames.clear();
    for (final path in paths) {
      var stream =
          Directory(p.join(path.path, "versions")).list(followLinks: false);
      try {
        await for (var dir in stream) {
          final json = p.join(dir.path, "${p.basename(dir.path)}.json");
          if (await Directory(p.join(path.path, dir.path)).exists() &&
              await File(json).exists()) {
            _availableGames.add(Game(dir.path));
          }
        }
      } catch (e) {
        e.printError();
      }
    }
  }

  factory GamePath.fromJson(Map<String, dynamic> json) =>
      _$GamePathFromJson(json);
  Map<String, dynamic> toJson() => _$GamePathToJson(this);

  static List<Map<String, dynamic>> toJsonList() {
    return json.decode(json.encode(paths));
  }

  static List<GamePath> fromJsonList(List<dynamic>? paths) {
    if (paths != null) {
      _paths.value = paths.map((path) => GamePath.fromJson(path)).toList();
    }
    return _paths;
  }
}
