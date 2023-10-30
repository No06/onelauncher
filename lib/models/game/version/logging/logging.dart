import 'package:one_launcher/models/game/version/logging/client_logging.dart';
import 'package:json_annotation/json_annotation.dart';

part 'logging.g.dart';

@JsonSerializable()
class Logging {
  Logging(this.client);

  final ClientLogging client;

  factory Logging.fromJson(Map<String, dynamic> json) =>
      _$LoggingFromJson(json);
}
