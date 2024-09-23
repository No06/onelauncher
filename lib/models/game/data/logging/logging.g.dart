// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logging.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Logging _$LoggingFromJson(Map<String, dynamic> json) => Logging(
      json['client'] == null
          ? null
          : ClientLogging.fromJson(json['client'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoggingToJson(Logging instance) => <String, dynamic>{
      'client': instance.client,
    };
