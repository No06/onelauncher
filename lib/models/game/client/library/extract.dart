import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'extract.g.dart';

@JsonSerializable()
class ExtractRule {
  ExtractRule({this.exclude});

  factory ExtractRule.fromJson(JsonMap json) => _$ExtractRuleFromJson(json);

  final List<String>? exclude;
  JsonMap toJson() => _$ExtractRuleToJson(this);
}
