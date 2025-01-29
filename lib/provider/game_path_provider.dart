import 'dart:io';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/main.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/models/game/game_path.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';
import 'package:path/path.dart';

part 'game_path_provider.g.dart';

class _GamePathUtils {
  static String getDefaultLauncherPath() {
    try {
      // 获取环境变量
      final env = Platform.isWindows ? 'APPDATA' : 'HOME';
      final value = Platform.environment[env];
      if (value == null) {
        throw Exception("Environment variable value not found: $env");
      }
      // 根据平台设置路径
      if (Platform.isWindows || Platform.isLinux) {
        return join(value, kGameDirectoryName);
      } else if (Platform.isMacOS) {
        return join(
            value, "Library", "Application Support", kGameDirectoryName,);
      } else {
        throw Exception("Unsupported platform: ${Platform.operatingSystem}");
      }
    } catch (e) {
      e.printError();
      return "unknown";
    }
  }

  static String getLauncherExecutablePath() {
    return join(
      File(Platform.resolvedExecutable).parent.path,
      kGameDirectoryName,
    );
  }
}

@JsonSerializable()
@CopyWith()
class GamePathState {

  GamePathState({Set<GamePath>? paths})
      : paths = paths ?? {...launcherGamePaths};

  factory GamePathState.fromJson(JsonMap json) => _$GamePathStateFromJson(json);
  final Set<GamePath> paths;

  /// 默认
  static final Set<GamePath> launcherGamePaths = {
    GamePath(
      name: "启动器目录",
      path: _GamePathUtils.getLauncherExecutablePath(),
    ),
    GamePath(
      name: "官方启动器目录",
      path: _GamePathUtils.getDefaultLauncherPath(),
    ),
  };

  /// 从游戏目录中搜索游戏
  Future<Iterable<Game>> getGamesOnPath() async {
    final gameList = await Future.wait(
      paths.map((path) => path.games.toList()),
    );
    return gameList.expand((list) => list);
  }

  Set<GamePath> get addedPaths => paths.difference(launcherGamePaths);

  JsonMap toJson() => _$GamePathStateToJson(this);
}

class GamePathStateNotifier extends StateNotifier<GamePathState> {
  GamePathStateNotifier() : super(_loadInitialState());

  static const storageKey = "gamePathState";

  static GamePathState _loadInitialState() {
    final storedData = storage.read<JsonMap>(storageKey);
    try {
      if (storedData != null) return GamePathState.fromJson(storedData);
    } catch (e) {
      e.printError();
    }
    return GamePathState();
  }

  void _saveState() {
    storageKey.printInfo("Save storage");
    storage.write(storageKey, state.toJson());
  }

  bool _updatePath(bool Function() updater) {
    final updated = updater();
    state = state.copyWith(paths: state.paths);
    _saveState();
    return updated;
  }

  bool addPath(GamePath value) {
    return _updatePath(() => state.paths.add(value));
  }

  bool removePath(GamePath value) {
    return _updatePath(() => state.paths.remove(value));
  }

  void clearPaths() {
    state.paths.clear();
    state = state.copyWith(paths: state.paths);
    _saveState();
  }
}

final gamePathProvider =
    StateNotifierProvider<GamePathStateNotifier, GamePathState>((ref) {
  return GamePathStateNotifier();
});
