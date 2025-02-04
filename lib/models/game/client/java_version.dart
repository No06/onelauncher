import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'java_version.g.dart';

@JsonSerializable()
class JavaVersion {
  const JavaVersion(this.component, this.majorVersion);

  factory JavaVersion.fromJson(JsonMap json) => _$JavaVersionFromJson(json);

  /// Its value for all 1.17 snapshots is "jre-legacy" until 21w18a and "java-runtime-alpha" since 21w19a.
  final String component;

  /// Its value for all 1.17 snapshots is 8 until 21w18a and 16 since 21w19a.
  final int majorVersion;
  JsonMap toJson() => _$JavaVersionToJson(this);
}
