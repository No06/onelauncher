// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'natives_librarie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NativesLibrarie _$NativesLibrarieFromJson(Map<String, dynamic> json) =>
    NativesLibrarie(
      name: json['name'] as String,
      downloads: Downloads.fromJson(json['downloads'] as Map<String, dynamic>),
      rules: (json['rules'] as List<dynamic>?)
          ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
          .toList(),
      natives: (json['natives'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$OsNameEnumMap, k), e as String),
      ),
      extract: json['extract'] == null
          ? null
          : Extract.fromJson(json['extract'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NativesLibrarieToJson(NativesLibrarie instance) =>
    <String, dynamic>{
      'name': instance.name,
      'downloads': instance.downloads,
      'rules': instance.rules,
      'natives':
          instance.natives.map((k, e) => MapEntry(_$OsNameEnumMap[k]!, e)),
      'extract': instance.extract,
    };

const _$OsNameEnumMap = {
  OsName.windows: 'windows',
  OsName.linux: 'linux',
  OsName.osx: 'osx',
};
