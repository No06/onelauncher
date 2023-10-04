import 'package:one_launcher/models/game/version/librarie/downloads.dart';
import 'package:one_launcher/models/game/version/librarie/extract.dart';
import 'package:one_launcher/models/game/version/librarie/librarie.dart';
import 'package:one_launcher/models/game/version/os.dart';
import 'package:one_launcher/models/game/version/rule.dart';
import 'package:json_annotation/json_annotation.dart';

part 'artifact_librarie.g.dart';

@JsonSerializable()
class ArtifactLibrarie extends Librarie {
  ArtifactLibrarie({
    required super.name,
    required this.downloads,
    this.rules,
    this.extract,
    this.natives,
  });

  final Downloads downloads;
  final List<Rule>? rules;
  final Extract? extract;
  final Map<OsName, String>? natives;

  factory ArtifactLibrarie.fromJson(Map<String, dynamic> json) =>
      _$ArtifactLibrarieFromJson(json);
}
