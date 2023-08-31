// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
      json['path'] as String,
      useGlobalSetting: json['useGlobalSetting'] as bool? ?? true,
      setting: json['setting'] == null
          ? null
          : GameSetting.fromJson(json['setting'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'path': instance.path,
      'useGlobalSetting': instance.useGlobalSetting,
      'setting': instance.setting,
    };
