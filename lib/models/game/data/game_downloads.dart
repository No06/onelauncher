import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/data/download_file.dart';
import 'package:one_launcher/models/json_map.dart';

part 'game_downloads.g.dart';

@JsonSerializable()
class GameDownloads {
  const GameDownloads(this.client);

  factory GameDownloads.fromJson(JsonMap json) => _$GameDownloadsFromJson(json);

  final DownloadFile client;
  JsonMap toJson() => _$GameDownloadsToJson(this);
}
