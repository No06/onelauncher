import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'arguments.g.dart';

@JsonSerializable()
class Arguments {
  const Arguments(this.game, this.jvm);

  factory Arguments.fromJson(JsonMap json) => _$ArgumentsFromJson(json);

  final List<dynamic>? game;
  final List<dynamic>? jvm;

  Iterable<String>? get gameFilterString => game?.whereType<String>();
  Iterable<String>? get jvmFilterString => jvm?.whereType<String>();

  JsonMap toJson() => _$ArgumentsToJson(this);
}
