import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/version/os_rule.dart';

part 'rule.g.dart';

@JsonSerializable()
class Rule {
  const Rule({required this.action});

  final RuleAction action;

  factory Rule.fromJson(Map<String, dynamic> json) {
    if (json['os'] != null) {
      return OsRule.fromJson(json);
    }
    return _$RuleFromJson(json);
  }
}

@JsonEnum()
enum RuleAction {
  allow("allow"),
  disallow("disallow");

  const RuleAction(this.action);
  final String action;
}
