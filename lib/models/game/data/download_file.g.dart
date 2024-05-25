// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadFile _$DownloadFileFromJson(Map<String, dynamic> json) => DownloadFile(
      id: json['id'] as String?,
      url: json['url'] as String,
      sha1: json['sha1'] as String,
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$DownloadFileToJson(DownloadFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'sha1': instance.sha1,
      'size': instance.size,
    };
