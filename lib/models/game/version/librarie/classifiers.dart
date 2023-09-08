import 'package:beacon/models/game/version/librarie/artifact.dart';
import 'package:json_annotation/json_annotation.dart';

part 'classifiers.g.dart';

@JsonSerializable()
class Classifiers {
  Classifiers({required this.linux, required this.osx, required this.windows});

  final Artifact linux;
  final Artifact osx;
  final Artifact windows;

  factory Classifiers.fromJson(Map<String, dynamic> json) =>
      _$ClassifiersFromJson(json);
}
