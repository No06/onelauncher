// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameData _$GameDataFromJson(Map<String, dynamic> json) => GameData(
      json['id'] as String,
      json['arguments'] == null
          ? null
          : Arguments.fromJson(json['arguments'] as Map<String, dynamic>),
      json['minecraftArguments'] as String?,
      json['mainClass'] as String,
      json['jar'] as String?,
      AssetIndex.fromJson(json['assetIndex'] as Map<String, dynamic>),
      JavaVersion.fromJson(json['javaVersion'] as Map<String, dynamic>),
      (json['libraries'] as List<dynamic>)
          .map((e) => Library.fromJson(e as Map<String, dynamic>))
          .toList(),
      GameDownloads.fromJson(json['downloads'] as Map<String, dynamic>),
      Logging.fromJson(json['logging'] as Map<String, dynamic>),
      $enumDecode(_$GameTypeEnumMap, json['type']),
      json['minimumLauncherVersion'] as int,
      json['clientVersion'] as String,
    );

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
      'id': instance.id,
      'arguments': instance.arguments,
      'minecraftArguments': instance.minecraftArguments,
      'mainClass': instance.mainClass,
      'jar': instance.jar,
      'assetIndex': instance.assetIndex,
      'javaVersion': instance.javaVersion,
      'libraries': instance.libraries,
      'downloads': instance.downloads,
      'logging': instance.logging,
      'type': _$GameTypeEnumMap[instance.type]!,
      'minimumLauncherVersion': instance.minimumLauncherVersion,
      'clientVersion': instance.clientVersion,
    };

const _$GameTypeEnumMap = {
  GameType.release: 'release',
  GameType.snapshot: 'snapshot',
  GameType.oldBeta: 'oldBeta',
  GameType.oldAlpha: 'oldAlpha',
};
