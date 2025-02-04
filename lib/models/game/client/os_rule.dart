import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/client/os.dart';
import 'package:one_launcher/models/game/client/rule.dart';
import 'package:one_launcher/models/json_map.dart';

part 'os_rule.g.dart';

@JsonSerializable()
class OsRule extends Rule {
  const OsRule(this.os, {required super.action});

  factory OsRule.fromJson(JsonMap json) => _$OsRuleFromJson(json);

  final Os os;
  @override
  JsonMap toJson() => _$OsRuleToJson(this);
}
