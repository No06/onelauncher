import 'package:beacon/models/game/version/game_type.dart';
import 'package:beacon/models/game/version/librarie/librarie.dart';
import 'package:beacon/models/game/version/asset_index.dart';
import 'package:beacon/models/game/version/game_downloads.dart';
import 'package:beacon/models/game/version/java_version.dart';
import 'package:beacon/models/game/version/logging/logging.dart';
import 'package:json_annotation/json_annotation.dart';

part 'version.g.dart';

@JsonSerializable()
class Version {
  Version(
    this.id,
    this.mainClass,
    this.jar,
    this.assetIndex,
    this.javaVersion,
    this.libraries,
    this.downloads,
    this.logging,
    this.type,
  );

  final String id;
  final String mainClass;
  final String jar;
  final AssetIndex assetIndex;
  final JavaVersion javaVersion;
  final List<Librarie> libraries;
  final GameDownloads downloads;
  final Logging logging;
  final GameType type;

  factory Version.fromJson(Map<String, dynamic> json) =>
      _$VersionFromJson(json);
}
