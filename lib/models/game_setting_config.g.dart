// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_setting_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameSettingConfig _$GameSettingConfigFromJson(Map<String, dynamic> json) =>
    GameSettingConfig(
      java: json['java'] as String?,
      defaultJvmArgs: json['defaultJvmArgs'] as bool?,
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

Map<String, dynamic> _$GameSettingConfigToJson(GameSettingConfig instance) =>
    <String, dynamic>{
      'java': instance.java,
      'defaultJvmArgs': instance.defaultJvmArgs,
      'jvmArgs': instance.jvmArgs,
      'autoMemory': instance.autoMemory,
      'maxMemory': instance.maxMemory,
      'fullScreen': instance.fullScreen,
      'width': instance.width,
      'height': instance.height,
      'log': instance.log,
      'args': instance.args,
      'serverAddress': instance.serverAddress,
    };
