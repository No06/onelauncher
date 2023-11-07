import 'package:json_annotation/json_annotation.dart';

part 'arguments.g.dart';

@JsonSerializable(createToJson: false)
class Arguments {
  const Arguments(this.game, this.jvm);

  final List<dynamic> game;
  final List<dynamic> jvm;

  factory Arguments.fromJson(Map<String, dynamic> json) =>
      _$ArgumentsFromJson(json);
}
