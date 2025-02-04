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

@JsonSerializable()
class Client {
  const Client(
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
    ClientDownloads? downloads,
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

  factory Client.fromJson(JsonMap json) => _$ClientFromJson(json);

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

  final ClientDownloads? _downloads;
  ClientDownloads? get downloads => _downloads ?? gamePatch?.downloads;

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
  final List<Client>? patches;

  Client? get gamePatch => patches?.firstWhere((patch) => patch.id == "game");

  String get jarFile => _jar == null ? "$id.jar" : "$_jar.jar";
  JsonMap toJson() => _$ClientToJson(this);
}
