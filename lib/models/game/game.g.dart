// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
      json['mainPath'] as String,
      json['versionPath'] as String,
      setting: json['setting'] == null
          ? null
          : GameSettingState.fromJson(json['setting'] as Map<String, dynamic>),
    );
