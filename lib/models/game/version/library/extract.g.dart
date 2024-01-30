// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExtractRule _$ExtractRuleFromJson(Map<String, dynamic> json) => ExtractRule(
      exclude:
          (json['exclude'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ExtractRuleToJson(ExtractRule instance) =>
    <String, dynamic>{
      'exclude': instance.exclude,
    };
