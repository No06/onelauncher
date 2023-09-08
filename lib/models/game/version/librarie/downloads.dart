import 'package:beacon/models/game/version/librarie/artifact.dart';
import 'package:beacon/models/game/version/librarie/classifiers.dart';
import 'package:json_annotation/json_annotation.dart';

part 'downloads.g.dart';

@JsonSerializable()
class Downloads {
  Downloads({required this.artifact, this.classifiers});

  final Artifact artifact;
  final Classifiers? classifiers;

  factory Downloads.fromJson(Map<String, dynamic> json) =>
      _$DownloadsFromJson(json);
}
