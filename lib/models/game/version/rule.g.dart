// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rule _$RuleFromJson(Map<String, dynamic> json) => Rule(
      action: $enumDecode(_$RuleActionEnumMap, json['action']),
    );

Map<String, dynamic> _$RuleToJson(Rule instance) => <String, dynamic>{
      'action': _$RuleActionEnumMap[instance.action]!,
    };

const _$RuleActionEnumMap = {
  RuleAction.allow: 'allow',
  RuleAction.disallow: 'disallow',
};
