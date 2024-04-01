import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'extract.g.dart';

@JsonSerializable()
class ExtractRule {
  ExtractRule({this.exclude});

  late final List<String>? exclude;

  factory ExtractRule.fromJson(JsonMap json) => _$ExtractRuleFromJson(json);
}
