import 'package:one_launcher/models/java.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_setting_config.g.dart';

const kDefaultJvmArgs =
    "-XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M";

@JsonSerializable()
class GameSettingConfig extends ChangeNotifier {
  GameSettingConfig({
    Java? java,
    String? jvmArgs,
    bool? autoMemory,
    int? maxMemory,
    bool? fullScreen,
    int? width,
    int? height,
    bool? log,
    String? args,
    String? serverAddress,
  })  : _java = ValueNotifier(_javaFromJson(java)),
        _jvmArgs = ValueNotifier(jvmArgs ?? kDefaultJvmArgs),
        _autoMemory = ValueNotifier(autoMemory ?? true),
        _maxMemory = ValueNotifier(maxMemory ?? 2048),
        _fullScreen = ValueNotifier(fullScreen ?? false),
        _width = ValueNotifier(width ?? 854),
        _height = ValueNotifier(height ?? 480),
        _log = ValueNotifier(log ?? false),
        _args = ValueNotifier(args ?? ""),
        _serverAddress = ValueNotifier(serverAddress ?? ""),
        super() {
    final notifiers = [
      _java,
      _jvmArgs,
      _autoMemory,
      _maxMemory,
      _fullScreen,
      _width,
      _height,
      _log,
      _args,
      _serverAddress,
    ];
    for (var notifier in notifiers) {
      notifier.addListener(notifyListeners);
    }
  }

  ValueNotifier<Java?> _java;
  ValueNotifier<String> _jvmArgs;
  ValueNotifier<bool> _autoMemory;
  ValueNotifier<int> _maxMemory;
  ValueNotifier<bool> _fullScreen;
  ValueNotifier<int> _width;
  ValueNotifier<int> _height;
  ValueNotifier<bool> _log;
  ValueNotifier<String> _args;
  ValueNotifier<String> _serverAddress;

  ValueNotifier<Java?> get javaNotifier => _java;
  @JsonKey(includeIfNull: false)
  Java? get java => _java.value;
  set java(Java? newVal) => _java.value = newVal;
  static Java? _javaFromJson(Java? item) {
    if (item == null) return null;
    if (JavaUtil.set.contains(item)) {
      return item;
    }
    return null;
  }

  ValueNotifier<String> get jvmArgsNotifier => _jvmArgs;
  String get jvmArgs => _jvmArgs.value;
  set jvmArgs(String newVal) => _jvmArgs.value = newVal;
  void restoreJvmArgs() => jvmArgs = kDefaultJvmArgs;

  ValueNotifier<bool> get autoMemoryNotifier => _autoMemory;
  bool get autoMemory => _autoMemory.value;
  set autoMemory(bool newVal) => _autoMemory.value = newVal;

  ValueNotifier<int> get maxMemoryNotifier => _maxMemory;
  int get maxMemory => _maxMemory.value;
  set maxMemory(int newVal) => _maxMemory.value = newVal;

  ValueNotifier<bool> get fullScreenNotifier => _fullScreen;
  bool get fullScreen => _fullScreen.value;
  set fullScreen(bool newVal) => _fullScreen.value = newVal;

  ValueNotifier<int> get widthNotifier => _width;
  int get width => _width.value;
  set width(int newVal) => _width.value = newVal;

  ValueNotifier<int> get heightNotifier => _height;
  int get height => _height.value;
  set height(int newVal) => _height.value = newVal;

  ValueNotifier<bool> get logNotifier => _log;
  bool get log => _log.value;
  set log(bool newVal) => _log.value = newVal;

  ValueNotifier<String> get argsNotifier => _args;
  String get args => _args.value;
  set args(String newVal) => _args.value = newVal;

  ValueNotifier<String> get serverAddressNotifier => _serverAddress;
  String get serverAddress => _serverAddress.value;
  set serverAddress(String newVal) => _serverAddress.value = newVal;

  factory GameSettingConfig.fromJson(Map<String, dynamic> json) =>
      _$GameSettingConfigFromJson(json);

  Map<String, dynamic> toJson() => _$GameSettingConfigToJson(this);
}
