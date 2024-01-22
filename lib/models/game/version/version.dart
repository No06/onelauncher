import 'package:one_launcher/models/game/version/arguments.dart';
import 'package:one_launcher/models/game/version/game_type.dart';
import 'package:one_launcher/models/game/version/librarie/librarie.dart';
import 'package:one_launcher/models/game/version/asset_index.dart';
import 'package:one_launcher/models/game/version/game_downloads.dart';
import 'package:one_launcher/models/game/version/java_version.dart';
import 'package:one_launcher/models/game/version/logging/logging.dart';
import 'package:json_annotation/json_annotation.dart';

part 'version.g.dart';

@JsonSerializable()
class Version {
  const Version(
    this.id,
    this.arguments,
    this.minecraftArguments,
    this.mainClass,
    this.jar,
    this.assetIndex,
    this.javaVersion,
    this.libraries,
    this.downloads,
    this.logging,
    this.type,
    this.minimumLauncherVersion,
  );

  final String id;
  final Arguments? arguments;
  final String? minecraftArguments;
  final String mainClass;
  final String? jar;
  final AssetIndex assetIndex;
  final JavaVersion javaVersion;
  final List<Library> libraries;
  final GameDownloads downloads;
  final Logging logging;
  final GameType type;
  final int minimumLauncherVersion;

  String get jarFile => "$jar.jar";

  factory Version.fromJson(Map<String, dynamic> json) =>
      _$VersionFromJson(json);
}
