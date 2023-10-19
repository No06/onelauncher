// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_librarie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommonLibrarie _$CommonLibrarieFromJson(Map<String, dynamic> json) =>
    CommonLibrarie(
      name: json['name'] as String,
      downloads: Downloads.fromJson(json['downloads'] as Map<String, dynamic>),
      rules: (json['rules'] as List<dynamic>?)
          ?.map((e) => Rule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CommonLibrarieToJson(CommonLibrarie instance) =>
    <String, dynamic>{
      'name': instance.name,
      'downloads': instance.downloads,
      'rules': instance.rules,
    };
