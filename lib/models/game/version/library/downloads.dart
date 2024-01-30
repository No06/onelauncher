import 'package:one_launcher/models/game/version/library/artifact.dart';
import 'package:json_annotation/json_annotation.dart';

part 'downloads.g.dart';

@JsonSerializable()
class Downloads {
  const Downloads({this.artifact, this.classifiers});

  final Artifact? artifact;
  final Map<String, Artifact>? classifiers;

  factory Downloads.fromJson(Map<String, dynamic> json) =>
      _$DownloadsFromJson(json);
}
