import 'package:one_launcher/models/game/data/library/artifact.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/data/library/classifiers.dart';
import 'package:one_launcher/models/json_map.dart';

part 'downloads.g.dart';

@JsonSerializable()
class Downloads {
  Downloads({this.artifact, this.classifiers});

  late final Artifact? artifact;
  late final Classifiers? classifiers;

  factory Downloads.fromJson(JsonMap json) => _$DownloadsFromJson(json);
}
