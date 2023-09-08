import 'package:beacon/models/game/version/download_file.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_downloads.g.dart';

@JsonSerializable()
class GameDownloads {
  GameDownloads(this.client);

  final DownloadFile client;

  factory GameDownloads.fromJson(Map<String, dynamic> json) =>
      _$GameDownloadsFromJson(json);
}
