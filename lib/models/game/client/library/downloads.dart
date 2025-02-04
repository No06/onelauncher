import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/client/library/artifact.dart';
import 'package:one_launcher/models/game/client/library/classifiers.dart';
import 'package:one_launcher/models/json_map.dart';

part 'downloads.g.dart';

@JsonSerializable()
class Downloads {
  Downloads({this.artifact, this.classifiers});

  factory Downloads.fromJson(JsonMap json) => _$DownloadsFromJson(json);

  final Artifact? artifact;
  final Classifiers? classifiers;
  JsonMap toJson() => _$DownloadsToJson(this);
}
