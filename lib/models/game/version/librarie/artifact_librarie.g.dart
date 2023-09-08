// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artifact_librarie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArtifactLibrarie _$ArtifactLibrarieFromJson(Map<String, dynamic> json) =>
    ArtifactLibrarie(
      name: json['name'] as String,
      downloads: Downloads.fromJson(json['downloads'] as Map<String, dynamic>),
      rules: (json['rules'] as List<dynamic>?)
          ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
          .toList(),
      extract: json['extract'] == null
          ? null
          : Extract.fromJson(json['extract'] as Map<String, dynamic>),
      natives: (json['natives'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$NativeEnumMap, e))
          .toSet(),
    );

Map<String, dynamic> _$ArtifactLibrarieToJson(ArtifactLibrarie instance) =>
    <String, dynamic>{
      'name': instance.name,
      'downloads': instance.downloads,
      'rules': instance.rules,
      'extract': instance.extract,
      'natives': instance.natives?.map((e) => _$NativeEnumMap[e]!).toList(),
    };

const _$NativeEnumMap = {
  Native.osx: 'osx',
  Native.linux: 'linux',
  Native.windows: 'windows',
};
