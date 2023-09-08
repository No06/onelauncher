// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Downloads _$DownloadsFromJson(Map<String, dynamic> json) => Downloads(
      artifact: Artifact.fromJson(json['artifact'] as Map<String, dynamic>),
      classifiers: json['classifiers'] == null
          ? null
          : Classifiers.fromJson(json['classifiers'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DownloadsToJson(Downloads instance) => <String, dynamic>{
      'artifact': instance.artifact,
      'classifiers': instance.classifiers,
    };
