import 'package:json_annotation/json_annotation.dart';

part 'game_setting.g.dart';

@JsonSerializable()
class GameSetting {
  GameSetting({
    this.java = "auto",
    this.defaultJvmArgs = true,
    this.jvmArgs = "",
    this.autoMemory = true,
    this.maxMemory = 2048,
    this.fullScreen = false,
    this.width = 854,
    this.height = 480,
    this.log = false,
    this.args = "",
    this.serverAddress = "",
  });

  String java;
  bool defaultJvmArgs;
  String jvmArgs;
  bool autoMemory;
  int maxMemory;
  bool fullScreen;
  int width;
  int height;
  bool log;
  String args;
  String serverAddress;

  factory GameSetting.fromJson(Map<String, dynamic> json) =>
      _$GameSettingFromJson(json);

  Map<String, dynamic> toJson() => _$GameSettingToJson(this);
}
