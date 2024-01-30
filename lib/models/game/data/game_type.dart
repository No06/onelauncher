import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum GameType {
  release("release"),
  snapshot("snapshot"),
  oldBeta("old_beta"),
  oldAlpha("old_alpha");

  const GameType(this.type);
  final String type;
}
