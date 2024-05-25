import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/main.dart';
import 'package:one_launcher/models/game/java.dart';
import 'package:one_launcher/models/json_map.dart';

part 'game_setting_provider.g.dart';

const _kDefaultJvmArgs =
    "-XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M";

@JsonSerializable()
@CopyWith()
class GameSettingState {
  final Java? java;
  final String? _jvmArgs;
  final bool autoMemory;
  final int maxMemory;
  final bool fullScreen;
  final int width;
  final int height;
  final bool recordLog;
  final String args;
  final String serverAddress;

  String get jvmArgs => useDefaultJvmArgs ? _kDefaultJvmArgs : _jvmArgs!;
  bool get useDefaultJvmArgs => _jvmArgs == null || _jvmArgs!.isEmpty;

  GameSettingState({
    this.java,
    String? jvmArgs,
    this.autoMemory = true,
    this.maxMemory = 2048,
    this.fullScreen = false,
    this.width = 854,
    this.height = 480,
    this.recordLog = false,
    this.args = "",
    this.serverAddress = "",
  }) : _jvmArgs = jvmArgs;

  JsonMap toJson() => _$GameSettingStateToJson(this);

  factory GameSettingState.fromJson(JsonMap json) =>
      _$GameSettingStateFromJson(json);
}

class GameSettingNotifier extends StateNotifier<GameSettingState> {
  GameSettingNotifier() : super(_loadInitialState());

  static const storageKey = "gameSetting";

  static GameSettingState _loadInitialState() {
    final storedData = storage.read<JsonMap>(storageKey);
    try {
      if (storedData != null) return GameSettingState.fromJson(storedData);
    } catch (e) {
      e.printError();
    }
    return GameSettingState();
  }

  void _saveState() => storage.write(storageKey, state.toJson());

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
    StateNotifierProvider<GameSettingNotifier, GameSettingState>((ref) {
  return GameSettingNotifier();
});
