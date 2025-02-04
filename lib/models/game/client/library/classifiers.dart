import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/client/library/artifact.dart';
import 'package:one_launcher/models/json_map.dart';

part "classifiers.g.dart";

@JsonSerializable()
class Classifiers {
  const Classifiers({
    this.linux,
    this.osx,
    this.windows,
    this.windows_32,
    this.windows_64,
  });

  factory Classifiers.fromJson(JsonMap json) => _$ClassifiersFromJson(json);

  @JsonKey(name: "natives-linux")
  final Artifact? linux;

  @JsonKey(name: "natives-osx")
  final Artifact? osx;

  @JsonKey(name: "natives-windows")
  final Artifact? windows;

  @JsonKey(name: "natives-windows-32")
  final Artifact? windows_32;

  @JsonKey(name: "natives-windows-64")
  final Artifact? windows_64;
  JsonMap toJson() => _$ClassifiersToJson(this);
}
