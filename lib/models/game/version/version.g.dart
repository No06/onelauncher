// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Version _$VersionFromJson(Map<String, dynamic> json) => Version(
      json['id'] as String,
      json['mainClass'] as String,
      json['jar'] as String,
      AssetIndex.fromJson(json['assetIndex'] as Map<String, dynamic>),
      JavaVersion.fromJson(json['javaVersion'] as Map<String, dynamic>),
      (json['libraries'] as List<dynamic>)
          .map((e) => Librarie.fromJson(e as Map<String, dynamic>))
          .toList(),
      GameDownloads.fromJson(json['downloads'] as Map<String, dynamic>),
      Logging.fromJson(json['logging'] as Map<String, dynamic>),
      $enumDecode(_$GameTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$VersionToJson(Version instance) => <String, dynamic>{
      'id': instance.id,
      'mainClass': instance.mainClass,
      'jar': instance.jar,
      'assetIndex': instance.assetIndex,
      'javaVersion': instance.javaVersion,
      'libraries': instance.libraries,
      'downloads': instance.downloads,
      'logging': instance.logging,
      'type': _$GameTypeEnumMap[instance.type]!,
    };

const _$GameTypeEnumMap = {
  GameType.release: 'release',
  GameType.snapshot: 'snapshot',
  GameType.oldBeta: 'oldBeta',
  GameType.oldAlpha: 'oldAlpha',
};
