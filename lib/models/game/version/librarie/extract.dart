import 'package:json_annotation/json_annotation.dart';

part 'extract.g.dart';

@JsonSerializable()
class Extract {
  Extract({this.exclude});

  final List<String>? exclude;

  factory Extract.fromJson(Map<String, dynamic> json) =>
      _$ExtractFromJson(json);
}
