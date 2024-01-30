import 'package:json_annotation/json_annotation.dart';

part 'extract.g.dart';

@JsonSerializable()
class ExtractRule {
  const ExtractRule({this.exclude});

  final List<String>? exclude;

  factory ExtractRule.fromJson(Map<String, dynamic> json) =>
      _$ExtractRuleFromJson(json);
}
