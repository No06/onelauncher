import 'package:one_launcher/models/game/data/download_file.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

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

  factory Artifact.fromJson(JsonMap json) => _$ArtifactFromJson(json);
  @override
  JsonMap toJson() => _$ArtifactToJson(this);
}
