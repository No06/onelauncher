// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'natives_library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NativesLibrary _$NativesLibraryFromJson(Map<String, dynamic> json) =>
    NativesLibrary(
      name: json['name'] as String,
      downloads: Downloads.fromJson(json['downloads'] as Map<String, dynamic>),
      natives: (json['natives'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$OsNameEnumMap, k), e as String),
      ),
      rules: (json['rules'] as List<dynamic>?)
          ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
          .toList(),
      extractRule: json['extract'] == null
          ? null
          : ExtractRule.fromJson(json['extract'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NativesLibraryToJson(NativesLibrary instance) =>
    <String, dynamic>{
      'name': instance.name,
      'downloads': instance.downloads,
      'rules': instance.rules,
      'natives':
          instance.natives.map((k, e) => MapEntry(_$OsNameEnumMap[k]!, e)),
      'extract': instance.extractRule,
    };

const _$OsNameEnumMap = {
  OsName.windows: 'windows',
  OsName.linux: 'linux',
  OsName.osx: 'osx',
  OsName.unknown: 'unknown',
};
