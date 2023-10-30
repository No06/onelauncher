import 'package:one_launcher/models/game/version/download_file.dart';
import 'package:json_annotation/json_annotation.dart';

part 'client_logging.g.dart';

@JsonSerializable()
class ClientLogging {
  ClientLogging(this.file, this.argument, this.type);

  final DownloadFile file;
  final String argument;
  final String type;

  factory ClientLogging.fromJson(Map<String, dynamic> json) =>
      _$ClientLoggingFromJson(json);
}
