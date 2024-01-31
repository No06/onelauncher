import 'package:one_launcher/models/game/data/library/artifact.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'downloads.g.dart';

@JsonSerializable()
class Downloads {
  const Downloads({this.artifact, this.classifiers});

  final Artifact? artifact;
  final Map<String, Artifact>? classifiers;

  factory Downloads.fromJson(JsonMap json) => _$DownloadsFromJson(json);
}
