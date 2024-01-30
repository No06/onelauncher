// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_logging.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientLogging _$ClientLoggingFromJson(Map<String, dynamic> json) =>
    ClientLogging(
      DownloadFile.fromJson(json['file'] as Map<String, dynamic>),
      json['argument'] as String,
      json['type'] as String,
    );

Map<String, dynamic> _$ClientLoggingToJson(ClientLogging instance) =>
    <String, dynamic>{
      'file': instance.file,
      'argument': instance.argument,
      'type': instance.type,
    };
