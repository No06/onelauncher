// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Extract _$ExtractFromJson(Map<String, dynamic> json) => Extract(
      exclude:
          (json['exclude'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ExtractToJson(Extract instance) => <String, dynamic>{
      'exclude': instance.exclude,
    };
