import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/main.dart';
import 'package:one_launcher/models/game/java.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';

part 'game_setting_provider.g.dart';

const _kDefaultJvmArgs =
    "-XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M";

@JsonSerializable()
@CopyWith()
class GameSetting {
  const GameSetting({
    this.java,
    this.jvmArgs,
    this.autoMemory = true,
    this.maxMemory = 2048,
    this.fullScreen = false,
    this.width = 854,
    this.height = 480,
    this.recordLog = false,
    this.args = "",
    this.serverAddress = "",
  });

  factory GameSetting.fromJson(JsonMap json) => _$GameSettingFromJson(json);
  final Java? java;
  final String? jvmArgs;
  final bool autoMemory;
  final int maxMemory;
  final bool fullScreen;
  final int width;
  final int height;
  final bool recordLog;
  final String args;
  final String serverAddress;

  /// 如果 [jvmArgs] 为空，则返回默认启动项 [_kDefaultJvmArgs]
  String get adaptiveJvmArgs => useDefaultJvmArgs ? _kDefaultJvmArgs : jvmArgs!;
  bool get useDefaultJvmArgs => jvmArgs == null || jvmArgs!.isEmpty;

  JsonMap toJson() => _$GameSettingToJson(this);
}

class GameSettingNotifier extends StateNotifier<GameSetting> {
  GameSettingNotifier() : super(_loadInitialState());

  static const storageKey = "gameSetting";

  static GameSetting _loadInitialState() {
    final storedData = storage.read<JsonMap>(storageKey);
    try {
      if (storedData != null) return GameSetting.fromJson(storedData);
    } catch (e) {
      e.printError();
    }
    return const GameSetting();
  }

  void _saveState() {
    storageKey.printInfo("Save storage");
    storage.write(storageKey, state.toJson());
  }

  void update({
    Java? java,
    String? jvmArgs,
    bool? autoMemory,
    int? maxMemory,
    bool? fullScreen,
    int? width,
    int? height,
    bool? recordLog,
    String? args,
    String? serverAddress,
  }) {
    state = state.copyWith(
      java: java,
      jvmArgs: jvmArgs,
      autoMemory: autoMemory,
      maxMemory: maxMemory,
      fullScreen: fullScreen,
      width: width,
      height: height,
      recordLog: recordLog,
      args: args,
      serverAddress: serverAddress,
    );
    _saveState();
  }
}

final gameSettingProvider =
    StateNotifierProvider<GameSettingNotifier, GameSetting>((ref) {
  return GameSettingNotifier();
});
