import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/data/logging/client_logging.dart';
import 'package:one_launcher/models/json_map.dart';

part 'logging.g.dart';

@JsonSerializable()
class Logging {
  Logging(this.client);

  factory Logging.fromJson(JsonMap json) => _$LoggingFromJson(json);

  final ClientLogging? client;
  JsonMap toJson() => _$LoggingToJson(this);
}
