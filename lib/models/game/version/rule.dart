import 'package:json_annotation/json_annotation.dart';

part 'rule.g.dart';

@JsonSerializable()
class Rule {
  Rule({required this.action});

  final Action action;

  factory Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);
}

@JsonEnum()
enum Action {
  allow("allow"),
  disallow("disallow");

  const Action(this.action);
  final String action;
}
