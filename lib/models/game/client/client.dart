import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/client/arguments.dart';
import 'package:one_launcher/models/game/client/asset_index.dart';
import 'package:one_launcher/models/game/client/client_downloads.dart';
import 'package:one_launcher/models/game/client/game_type.dart';
import 'package:one_launcher/models/game/client/java_version.dart';
import 'package:one_launcher/models/game/client/library/library.dart';
import 'package:one_launcher/models/game/client/logging/logging.dart';
import 'package:one_launcher/models/json_map.dart';

part 'client.g.dart';

/// client.json is the file that accompanies client.jar in `.minecraft/versions/<version>` and lists the version's attributes.
/// When using the latest version of the Minecraft launcher, it is named `<game version>.json`.
/// The JSON file for specific versions is located in the `version_manifest.json` file.
/// docs: https://minecraft.fandom.com/wiki/Client.json
@JsonSerializable()
class Client {
  const Client({
    required this.id,
    required this.arguments,
    required this.mainClass,
    required this.jar,
    required this.assetIndex,
    required this.assets,
    required this.complianceLevel,
    required this.javaVersion,
    required this.libraries,
    required this.downloads,
    required this.logging,
    required this.releaseTime,
    required this.type,
    required this.minimumLauncherVersion,
  });

  factory Client.fromJson(JsonMap json) => _$ClientFromJson(json);

  /// The name of this version client (e.g. 1.14.4).
  final String id;
  final Arguments arguments;

  /// The main game class; for modern versions, it is net.minecraft.client.main.Main, but it may differ for older or ancient versions.
  final String mainClass;
  final String? jar;
  final AssetIndex assetIndex;

  /// The assets version.
  final String assets;

  /// Its value is `1` for all recent versions of the game (1.16.4 and above) or 0 for all others.
  /// This tag tells the launcher whether it should urge the user to be careful since this version is older and might not support the latest player safety features.
  @JsonKey(defaultValue: 0)
  final int complianceLevel;

  /// The version of the Java Runtime Environment.
  final JavaVersion javaVersion;

  /// A list of libraries.
  final List<Library> libraries;
  final ClientDownloads downloads;

  /// Information about Log4j log configuration.
  final Logging logging;

  /// The release date and time.
  final DateTime releaseTime;

  /// Same as "releaseTime".
  DateTime get time => releaseTime;

  /// The type of this game version.
  /// It is shown in the version list when you create a new installation.
  /// The default values are "release" and "snapshot".
  final GameType type;
  final int minimumLauncherVersion;

  String get jarFile => "$jar.jar";
  JsonMap toJson() => _$ClientToJson(this);
}
