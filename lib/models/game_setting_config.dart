import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_setting_config.g.dart';

@JsonSerializable()
class GameSettingConfig extends ChangeNotifier {
  GameSettingConfig({
    String? java,
    bool? defaultJvmArgs,
    String? jvmArgs,
    bool? autoMemory,
    int? maxMemory,
    bool? fullScreen,
    int? width,
    int? height,
    bool? log,
    String? args,
    String? serverAddress,
  })  : _java = ValueNotifier(java ?? "auto"),
        _defaultJvmArgs = ValueNotifier(defaultJvmArgs ?? true),
        _jvmArgs = ValueNotifier(jvmArgs ?? ""),
        _autoMemory = ValueNotifier(autoMemory ?? true),
        _maxMemory = ValueNotifier(maxMemory ?? 2048),
        _fullScreen = ValueNotifier(fullScreen ?? false),
        _width = ValueNotifier(width ?? 854),
        _height = ValueNotifier(height ?? 480),
        _log = ValueNotifier(log ?? false),
        _args = ValueNotifier(args ?? ""),
        _serverAddress = ValueNotifier(serverAddress ?? ""),
        super() {
    _java.addListener(notifyListeners);
    _defaultJvmArgs.addListener(notifyListeners);
    _jvmArgs.addListener(notifyListeners);
    _autoMemory.addListener(notifyListeners);
    _maxMemory.addListener(notifyListeners);
    _fullScreen.addListener(notifyListeners);
    _width.addListener(notifyListeners);
    _height.addListener(notifyListeners);
    _log.addListener(notifyListeners);
    _args.addListener(notifyListeners);
    _serverAddress.addListener(notifyListeners);
  }

  ValueNotifier<String> _java;
  ValueNotifier<bool> _defaultJvmArgs;
  ValueNotifier<String> _jvmArgs;
  ValueNotifier<bool> _autoMemory;
  ValueNotifier<int> _maxMemory;
  ValueNotifier<bool> _fullScreen;
  ValueNotifier<int> _width;
  ValueNotifier<int> _height;
  ValueNotifier<bool> _log;
  ValueNotifier<String> _args;
  ValueNotifier<String> _serverAddress;

  String get java => _java.value;
  set java(String newVal) => _java.value = newVal;

  bool get defaultJvmArgs => _defaultJvmArgs.value;
  set defaultJvmArgs(bool newVal) => _defaultJvmArgs.value = newVal;

  String get jvmArgs => _jvmArgs.value;
  set jvmArgs(String newVal) => _jvmArgs.value = newVal;

  bool get autoMemory => _autoMemory.value;
  set autoMemory(bool newVal) => _autoMemory.value = newVal;

  int get maxMemory => _maxMemory.value;
  set maxMemory(int newVal) => _maxMemory.value = newVal;

  bool get fullScreen => _fullScreen.value;
  set fullScreen(bool newVal) => _fullScreen.value = newVal;

  int get width => _width.value;
  set width(int newVal) => _width.value = newVal;

  int get height => _height.value;
  set height(int newVal) => _height.value = newVal;

  bool get log => _log.value;
  set log(bool newVal) => _log.value = newVal;

  String get args => _args.value;
  set args(String newVal) => _args.value = newVal;

  String get serverAddress => _serverAddress.value;
  set serverAddress(String newVal) => _serverAddress.value = newVal;

  factory GameSettingConfig.fromJson(Map<String, dynamic> json) =>
      _$GameSettingConfigFromJson(json);

  Map<String, dynamic> toJson() => _$GameSettingConfigToJson(this);
}
