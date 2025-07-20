// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Client _$ClientFromJson(Map<String, dynamic> json) => Client(
      id: json['id'] as String,
      arguments: Arguments.fromJson(json['arguments'] as Map<String, dynamic>),
      mainClass: json['mainClass'] as String,
      jar: json['jar'] as String?,
      assetIndex:
          AssetIndex.fromJson(json['assetIndex'] as Map<String, dynamic>),
      assets: json['assets'] as String,
      complianceLevel: (json['complianceLevel'] as num?)?.toInt() ?? 0,
      javaVersion:
          JavaVersion.fromJson(json['javaVersion'] as Map<String, dynamic>),
      libraries: (json['libraries'] as List<dynamic>)
          .map((e) => Library.fromJson(e as Map<String, dynamic>))
          .toList(),
      downloads:
          ClientDownloads.fromJson(json['downloads'] as Map<String, dynamic>),
      logging: Logging.fromJson(json['logging'] as Map<String, dynamic>),
      releaseTime: DateTime.parse(json['releaseTime'] as String),
      type: $enumDecode(_$GameTypeEnumMap, json['type']),
      minimumLauncherVersion: (json['minimumLauncherVersion'] as num).toInt(),
    );

Map<String, dynamic> _$ClientToJson(Client instance) => <String, dynamic>{
      'id': instance.id,
      'arguments': instance.arguments,
      'mainClass': instance.mainClass,
      'jar': instance.jar,
      'assetIndex': instance.assetIndex,
      'assets': instance.assets,
      'complianceLevel': instance.complianceLevel,
      'javaVersion': instance.javaVersion,
      'libraries': instance.libraries,
      'downloads': instance.downloads,
      'logging': instance.logging,
      'releaseTime': instance.releaseTime.toIso8601String(),
      'type': _$GameTypeEnumMap[instance.type]!,
      'minimumLauncherVersion': instance.minimumLauncherVersion,
    };

const _$GameTypeEnumMap = {
  GameType.release: 'release',
  GameType.snapshot: 'snapshot',
  GameType.oldBeta: 'oldBeta',
  GameType.oldAlpha: 'oldAlpha',
};
