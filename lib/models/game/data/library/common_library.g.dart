// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommonLibrary _$CommonLibraryFromJson(Map<String, dynamic> json) =>
    CommonLibrary(
      name: json['name'] as String,
      downloads: Downloads.fromJson(json['downloads'] as Map<String, dynamic>),
      rules: (json['rules'] as List<dynamic>?)
          ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CommonLibraryToJson(CommonLibrary instance) =>
    <String, dynamic>{
      'name': instance.name,
      'downloads': instance.downloads,
      'rules': instance.rules,
    };
