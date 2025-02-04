import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/client/download_file.dart';
import 'package:one_launcher/models/json_map.dart';

part 'client_logging.g.dart';

@JsonSerializable()
class ClientLogging {
  ClientLogging(this.file, this.argument, this.type);

  factory ClientLogging.fromJson(JsonMap json) => _$ClientLoggingFromJson(json);

  final DownloadFile file;
  final String argument;
  final String type;
  JsonMap toJson() => _$ClientLoggingToJson(this);
}
