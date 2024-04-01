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
  late final String id;
  late final Arguments? arguments;
  late final String? minecraftArguments;
  late final String mainClass;
  late final String? jar;
  late final AssetIndex assetIndex;
  late final JavaVersion? javaVersion;
  late final List<Library> libraries;
  late final GameDownloads downloads;
  late final Logging? logging;
  late final GameType type;
  late final int minimumLauncherVersion;
  late final String? clientVersion;

  String get jarFile => jar == null ? "$id.jar" : "$jar.jar";

  factory GameData.fromJson(JsonMap json) => _$GameDataFromJson(json);
}
