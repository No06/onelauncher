import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'java_version.g.dart';

@JsonSerializable()
class JavaVersion {
  const JavaVersion(this.component, this.majorVersion);

  final String component;
  final int majorVersion;

  factory JavaVersion.fromJson(JsonMap json) => _$JavaVersionFromJson(json);
}
