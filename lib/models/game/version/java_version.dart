import 'package:json_annotation/json_annotation.dart';

part 'java_version.g.dart';

@JsonSerializable()
class JavaVersion {
  JavaVersion(this.component, this.majorVersion);

  final String component;
  final int majorVersion;

  factory JavaVersion.fromJson(Map<String, dynamic> json) =>
      _$JavaVersionFromJson(json);
}
