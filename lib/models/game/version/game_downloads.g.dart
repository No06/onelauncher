// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_downloads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameDownloads _$GameDownloadsFromJson(Map<String, dynamic> json) =>
    GameDownloads(
      DownloadFile.fromJson(json['client'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GameDownloadsToJson(GameDownloads instance) =>
    <String, dynamic>{
      'client': instance.client,
    };
