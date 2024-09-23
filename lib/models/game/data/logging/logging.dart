import 'package:one_launcher/models/game/data/logging/client_logging.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'logging.g.dart';

@JsonSerializable()
class Logging {
  Logging(this.client);

  final ClientLogging? client;

  factory Logging.fromJson(JsonMap json) => _$LoggingFromJson(json);
  JsonMap toJson() => _$LoggingToJson(this);
}
