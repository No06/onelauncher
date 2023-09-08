import 'dart:io';
import 'dart:convert';
import 'package:beacon/consts.dart';
import 'package:beacon/models/game/version/version.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';

import '../game_setting_config.dart';

part 'game.g.dart';

@JsonSerializable()
class Game {
  Game(
    String path, {
    bool? useGlobalSetting,
    GameSettingConfig? setting,
  })  : _useGlobalSetting = ValueNotifier(useGlobalSetting ?? false),
        _setting = setting ?? GameSettingConfig(),
        _path = path,
        _version = _getVersionFromPath(path) {
    _useGlobalSetting.addListener(saveConfig);
    _setting.addListener(saveConfig);
  }

  String _path; // .minecraft/version/xxx
  @JsonKey(includeToJson: false)
  String get path => _path;
  Version _version;
  Version get version => _version;

  ValueNotifier<bool> _useGlobalSetting;
  GameSettingConfig _setting;

  void freshVersion() => _version = _getVersionFromPath(_path);

  void saveConfig() {
    final config = File(_path + kGameConfigName);
    final json = const JsonEncoder.withIndent('  ').convert(this);
    config.writeAsStringSync(json);
  }

  static Version _getVersionFromPath(String path) {
    return Version.fromJson(jsonDecode(
        File(join(path, "${basename(path)}.json")).readAsStringSync()));
  }

  factory Game.fromJson(String path, Map<String, dynamic> json) {
    json.addAll({"path": path});
    return _$GameFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GameToJson(this);
}
