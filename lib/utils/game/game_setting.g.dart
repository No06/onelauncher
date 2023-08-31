// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameSetting _$GameSettingFromJson(Map<String, dynamic> json) => GameSetting(
      java: json['java'] as String? ?? "auto",
      defaultJvmArgs: json['defaultJvmArgs'] as bool? ?? true,
      jvmArgs: json['jvmArgs'] as String? ?? "",
      autoMemory: json['autoMemory'] as bool? ?? true,
      maxMemory: json['maxMemory'] as int? ?? 2048,
      fullScreen: json['fullScreen'] as bool? ?? false,
      width: json['width'] as int? ?? 854,
      height: json['height'] as int? ?? 480,
      log: json['log'] as bool? ?? false,
      args: json['args'] as String? ?? "",
      serverAddress: json['serverAddress'] as String? ?? "",
    );

Map<String, dynamic> _$GameSettingToJson(GameSetting instance) =>
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
