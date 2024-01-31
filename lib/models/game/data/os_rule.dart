import 'package:one_launcher/models/game/data/os.dart';
import 'package:one_launcher/models/game/data/rule.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'os_rule.g.dart';

@JsonSerializable()
class OsRule extends Rule {
  const OsRule(this.os, {required super.action});

  final Os os;

  factory OsRule.fromJson(JsonMap json) => _$OsRuleFromJson(json);
}
