import 'package:one_launcher/models/game/data/download_file.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'client_logging.g.dart';

@JsonSerializable()
class ClientLogging {
  ClientLogging(this.file, this.argument, this.type);

  final DownloadFile file;
  final String argument;
  final String type;

  factory ClientLogging.fromJson(JsonMap json) => _$ClientLoggingFromJson(json);
  JsonMap toJson() => _$ClientLoggingToJson(this);
}
