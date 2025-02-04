import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/client/download_file.dart';
import 'package:one_launcher/models/json_map.dart';

part 'client_downloads.g.dart';

@JsonSerializable()
class ClientDownloads {
  const ClientDownloads(this.client);

  factory ClientDownloads.fromJson(JsonMap json) =>
      _$ClientDownloadsFromJson(json);

  final DownloadFile client;
  JsonMap toJson() => _$ClientDownloadsToJson(this);
}
