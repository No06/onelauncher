// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artifact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Artifact _$ArtifactFromJson(Map<String, dynamic> json) => Artifact(
      json['path'] as String,
      url: json['url'] as String,
      sha1: json['sha1'] as String,
      size: json['size'] as int,
    );

Map<String, dynamic> _$ArtifactToJson(Artifact instance) => <String, dynamic>{
      'url': instance.url,
      'sha1': instance.sha1,
      'size': instance.size,
      'path': instance.path,
    };
