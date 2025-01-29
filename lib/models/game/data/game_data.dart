import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/data/arguments.dart';
import 'package:one_launcher/models/game/data/asset_index.dart';
import 'package:one_launcher/models/game/data/game_downloads.dart';
import 'package:one_launcher/models/game/data/game_type.dart';
import 'package:one_launcher/models/game/data/java_version.dart';
import 'package:one_launcher/models/game/data/library/library.dart';
import 'package:one_launcher/models/game/data/logging/logging.dart';
import 'package:one_launcher/models/json_map.dart';

part 'game_data.g.dart';

@JsonSerializable()
class GameData {
  const GameData(
    this.id,
    this.patches, {
    required this.root,
    required List<Library> libraries,
    Arguments? arguments,
    String? minecraftArguments,
    String? mainClass,
    String? jar,
    AssetIndex? assetIndex,
    JavaVersion? javaVersion,
    GameDownloads? downloads,
    Logging? logging,
    GameType? type,
    int? minimumLauncherVersion,
    String? clientVersion,
  })  : _arguments = arguments,
        _minecraftArguments = minecraftArguments,
        _mainClass = mainClass,
        _jar = jar,
        _assetIndex = assetIndex,
        _javaVersion = javaVersion,
        _libraries = libraries,
        _downloads = downloads,
        _logging = logging,
        _type = type,
        _minimumLauncherVersion = minimumLauncherVersion,
        _clientVersion = clientVersion;

  factory GameData.fromJson(JsonMap json) => _$GameDataFromJson(json);

  ///游戏名 可能是版本号，也可能是自定义的名字
  final String id;
  final Arguments? _arguments;
  Arguments? get arguments => _arguments ?? gamePatch?._arguments;

  final String? _minecraftArguments;
  String? get minecraftArguments =>
      _minecraftArguments ?? gamePatch?._minecraftArguments;

  final String? _mainClass;
  String? get mainClass => _mainClass ?? gamePatch?.mainClass;

  final String? _jar;
  String? get jar => _jar ?? gamePatch?.jar;

  final AssetIndex? _assetIndex;
  AssetIndex? get assetIndex => _assetIndex ?? gamePatch?.assetIndex;

  final JavaVersion? _javaVersion;
  JavaVersion? get javaVersion => _javaVersion ?? gamePatch?.javaVersion;

  final List<Library> _libraries;
  List<Library> get libraries =>
      _libraries.toSet().union(gamePatch?.libraries.toSet() ?? {}).toList();

  final GameDownloads? _downloads;
  GameDownloads? get downloads => _downloads ?? gamePatch?.downloads;

  final Logging? _logging;
  Logging? get logging => _logging ?? gamePatch?.logging;

  final GameType? _type;
  GameType? get type => _type ?? gamePatch?._type;

  final int? _minimumLauncherVersion;
  int? get minimumLauncherVersion =>
      _minimumLauncherVersion ?? gamePatch?.minimumLauncherVersion;

  final String? _clientVersion;
  String? get clientVersion => _clientVersion ?? gamePatch?.clientVersion;

  @JsonKey(defaultValue: false)
  final bool root;
  final List<GameData>? patches;

  GameData? get gamePatch => patches?.firstWhere((patch) => patch.id == "game");

  String get jarFile => _jar == null ? "$id.jar" : "$_jar.jar";
  JsonMap toJson() => _$GameDataToJson(this);
}
