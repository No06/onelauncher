// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetIndex _$AssetIndexFromJson(Map<String, dynamic> json) => AssetIndex(
      json['totalSize'] as int,
      id: json['id'] as String?,
      url: json['url'] as String,
      sha1: json['sha1'] as String,
      size: json['size'] as int,
    );

Map<String, dynamic> _$AssetIndexToJson(AssetIndex instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'sha1': instance.sha1,
      'size': instance.size,
      'totalSize': instance.totalSize,
    };
