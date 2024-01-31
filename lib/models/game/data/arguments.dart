import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'arguments.g.dart';

@JsonSerializable()
class Arguments {
  const Arguments(this.game, this.jvm);

  final List<dynamic> game;
  final List<dynamic> jvm;

  factory Arguments.fromJson(JsonMap json) => _$ArgumentsFromJson(json);

  JsonMap toJson() => _$ArgumentsToJson(this);
}
