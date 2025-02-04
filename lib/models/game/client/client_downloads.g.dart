// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_downloads.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientDownloads _$ClientDownloadsFromJson(Map<String, dynamic> json) =>
    ClientDownloads(
      DownloadFile.fromJson(json['client'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClientDownloadsToJson(ClientDownloads instance) =>
    <String, dynamic>{
      'client': instance.client,
    };
