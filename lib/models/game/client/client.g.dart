// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Client _$ClientFromJson(Map<String, dynamic> json) => Client(
      json['id'] as String,
      (json['patches'] as List<dynamic>?)
          ?.map((e) => Client.fromJson(e as Map<String, dynamic>))
          .toList(),
      root: json['root'] as bool? ?? false,
      libraries: (json['libraries'] as List<dynamic>)
          .map((e) => Library.fromJson(e as Map<String, dynamic>))
          .toList(),
      arguments: json['arguments'] == null
          ? null
          : Arguments.fromJson(json['arguments'] as Map<String, dynamic>),
      minecraftArguments: json['minecraftArguments'] as String?,
      mainClass: json['mainClass'] as String?,
      jar: json['jar'] as String?,
      assetIndex: json['assetIndex'] == null
          ? null
          : AssetIndex.fromJson(json['assetIndex'] as Map<String, dynamic>),
      javaVersion: json['javaVersion'] == null
          ? null
          : JavaVersion.fromJson(json['javaVersion'] as Map<String, dynamic>),
      downloads: json['downloads'] == null
          ? null
          : ClientDownloads.fromJson(json['downloads'] as Map<String, dynamic>),
      logging: json['logging'] == null
          ? null
          : Logging.fromJson(json['logging'] as Map<String, dynamic>),
      type: $enumDecodeNullable(_$GameTypeEnumMap, json['type']),
      minimumLauncherVersion: (json['minimumLauncherVersion'] as num?)?.toInt(),
      clientVersion: json['clientVersion'] as String?,
    );

Map<String, dynamic> _$ClientToJson(Client instance) => <String, dynamic>{
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
      'type': _$GameTypeEnumMap[instance.type],
      'minimumLauncherVersion': instance.minimumLauncherVersion,
      'clientVersion': instance.clientVersion,
      'root': instance.root,
      'patches': instance.patches,
    };

const _$GameTypeEnumMap = {
  GameType.release: 'release',
  GameType.snapshot: 'snapshot',
  GameType.oldBeta: 'oldBeta',
  GameType.oldAlpha: 'oldAlpha',
};
