// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'os_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OsRule _$OsRuleFromJson(Map<String, dynamic> json) => OsRule(
      Os.fromJson(json['os'] as Map<String, dynamic>),
      action: $enumDecode(_$ActionEnumMap, json['action']),
    );

Map<String, dynamic> _$OsRuleToJson(OsRule instance) => <String, dynamic>{
      'action': _$ActionEnumMap[instance.action]!,
      'os': instance.os,
    };

const _$ActionEnumMap = {
  Action.allow: 'allow',
  Action.disallow: 'disallow',
};
