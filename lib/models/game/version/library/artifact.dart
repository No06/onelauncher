import 'package:one_launcher/models/game/version/download_file.dart';
import 'package:json_annotation/json_annotation.dart';

part 'artifact.g.dart';

@JsonSerializable()
class Artifact extends DownloadFile {
  const Artifact(
    this.path, {
    required super.url,
    required super.sha1,
    required super.size,
  });

  final String path;

  factory Artifact.fromJson(Map<String, dynamic> json) =>
      _$ArtifactFromJson(json);
}
