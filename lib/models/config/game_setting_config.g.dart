// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_setting_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameSettingConfig _$GameSettingConfigFromJson(Map<String, dynamic> json) =>
    GameSettingConfig(
      java: json['java'] == null
          ? null
          : Java.fromJson(json['java'] as Map<String, dynamic>),
      jvmArgs: json['jvmArgs'] as String?,
      autoMemory: json['autoMemory'] as bool?,
      maxMemory: json['maxMemory'] as int?,
      fullScreen: json['fullScreen'] as bool?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      log: json['log'] as bool?,
      args: json['args'] as String?,
      serverAddress: json['serverAddress'] as String?,
    );

Map<String, dynamic> _$GameSettingConfigToJson(GameSettingConfig instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('java', instance.java);
  val['jvmArgs'] = GameSettingConfig.jvmArgsToJson(instance.jvmArgs);
  val['autoMemory'] = instance.autoMemory;
  val['maxMemory'] = instance.maxMemory;
  val['fullScreen'] = instance.fullScreen;
  val['width'] = instance.width;
  val['height'] = instance.height;
  val['log'] = instance.log;
  val['args'] = instance.args;
  val['serverAddress'] = instance.serverAddress;
  return val;
}
