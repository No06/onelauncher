import 'package:one_launcher/models/game/version/os.dart';
import 'package:one_launcher/models/game/version/rule.dart';
import 'package:json_annotation/json_annotation.dart';

part 'os_rule.g.dart';

@JsonSerializable()
class OsRule extends Rule {
  OsRule(this.os, {required super.action});

  final Os os;

  factory OsRule.fromJson(Map<String, dynamic> json) => _$OsRuleFromJson(json);
}
