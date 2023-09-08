// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rule _$RuleFromJson(Map<String, dynamic> json) => Rule(
      action: $enumDecode(_$ActionEnumMap, json['action']),
    );

Map<String, dynamic> _$RuleToJson(Rule instance) => <String, dynamic>{
      'action': _$ActionEnumMap[instance.action]!,
    };

const _$ActionEnumMap = {
  Action.allow: 'allow',
  Action.disallow: 'disallow',
};
