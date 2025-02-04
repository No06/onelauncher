import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'java_version.g.dart';

@JsonSerializable()
class JavaVersion {
  const JavaVersion(this.component, this.majorVersion);

  factory JavaVersion.fromJson(JsonMap json) => _$JavaVersionFromJson(json);

  final String component;
  final int majorVersion;
  JsonMap toJson() => _$JavaVersionToJson(this);
}
