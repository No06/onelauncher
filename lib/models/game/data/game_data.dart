import 'package:one_launcher/models/game/data/arguments.dart';
import 'package:one_launcher/models/game/data/game_type.dart';
import 'package:one_launcher/models/game/data/library/library.dart';
import 'package:one_launcher/models/game/data/asset_index.dart';
import 'package:one_launcher/models/game/data/game_downloads.dart';
import 'package:one_launcher/models/game/data/java_version.dart';
import 'package:one_launcher/models/game/data/logging/logging.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'game_data.g.dart';

@JsonSerializable()
class GameData {
  GameData(
    this.id,
    this.arguments,
    this.minecraftArguments,
    this.mainClass,
    this.jar,
    this.assetIndex,
    this.libraries,
    this.downloads,
    this.logging,
    this.type,
    this.minimumLauncherVersion, {
    this.javaVersion,
    this.clientVersion,
  });

  ///游戏名 可能是版本号，也可能是自定义的名字
  final String id;
  final Arguments? arguments;
  final String? minecraftArguments;
  final String mainClass;
  final String? jar;
  final AssetIndex assetIndex;
  final JavaVersion? javaVersion;
  final List<Library> libraries;
  final GameDownloads downloads;
  final Logging? logging;
  final GameType type;
  final int minimumLauncherVersion;
  final String? clientVersion;

  String get jarFile => jar == null ? "$id.jar" : "$jar.jar";

  factory GameData.fromJson(JsonMap json) => _$GameDataFromJson(json);
  JsonMap toJson() => _$GameDataToJson(this);
}
