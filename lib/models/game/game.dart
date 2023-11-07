import 'dart:io';
import 'dart:convert';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/account/account.dart';
import 'package:one_launcher/models/account/offline_account.dart';
import 'package:one_launcher/models/game/version/librarie/common_librarie.dart';
import 'package:one_launcher/models/game/version/librarie/librarie.dart';
import 'package:one_launcher/models/game/version/librarie/maven_librarie.dart';
import 'package:one_launcher/models/game/version/librarie/natives_librarie.dart';
import 'package:one_launcher/models/game/version/version.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/java.dart';
import 'package:one_launcher/utils/random_string.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../game_setting_config.dart';

part 'game.g.dart';

typedef ResultMap = Map<Librarie, bool>;

@JsonSerializable()
class Game {
  Game(
    String mainPath,
    String versionPath, {
    bool? useGlobalSetting,
    GameSettingConfig? setting,
  })  : _mainPath = mainPath,
        _versionPath = versionPath,
        _useGlobalSetting = ValueNotifier(useGlobalSetting ?? false),
        _librariesPath = (join(mainPath, librariesDirectory)),
        _setting = setting ?? GameSettingConfig(),
        _version = _getVersionFromPath(join(mainPath, versionPath)) {
    _useGlobalSetting.addListener(saveConfig);
    _setting.addListener(saveConfig);
  }

  static const librariesDirectory = "libraries";

  final String _mainPath;
  @JsonKey(includeToJson: false)
  String get mainPath => _mainPath;

  final String _versionPath;
  @JsonKey(includeToJson: false)
  String get versionPath => _versionPath;

  final String _librariesPath;
  @JsonKey(includeToJson: false)
  String get librariesPath => _librariesPath;

  String get path => join(_mainPath, _versionPath);

  Version _version;
  Version get version => _version;

  ValueNotifier<bool> _useGlobalSetting;
  GameSettingConfig _setting;
  GameSettingConfig? get setting => _setting;

  void freshVersion() => _version = _getVersionFromPath(path);

  void saveConfig() {
    final config = File(path + kGameConfigName);
    final json = const JsonEncoder.withIndent('  ').convert(this);
    config.writeAsStringSync(json);
  }

  String get assetsPath => join(_mainPath, "assets");
  String get loggingFilePath =>
      join(assetsPath, _version.logging.client.file.id);

  bool get isModVersion =>
      _version.mainClass != "net.minecraft.client.main.Main";

  Future<String> get randomOutputPath async {
    while (true) {
      final random = generateRandomString(8);
      final outputPath = join((await getApplicationDocumentsDirectory()).path,
          "minecraft-${_version.id}-natives-$random");
      if (!await Directory(outputPath).exists()) {
        return outputPath;
      }
    }
  }

  Stream<Librarie> get retrieveNonExitedLibraries async* {
    String? outputPath;
    for (var lib in version.libraries) {
      if (lib is MavenLibrarie) {
        if (!await lib.exists(_librariesPath)) yield lib;
      } else if (lib is CommonLibrarie && lib.isAllowed) {
        if (lib is NativesLibrarie) {
          outputPath ??= await randomOutputPath;
          await lib.extract(_librariesPath, outputPath);
        } else {
          if (!await lib.exists(_librariesPath)) yield lib;
        }
      }
    }
  }

  // TODO: 支持正版用户
  String getStartupCommandLine({
    required Java java,
    required Account account,
  }) {
    if (account is! OfflineAccount) {
      throw UnimplementedError();
    }
    return '"${java.path}" -XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump';
  }

  static Version _getVersionFromPath(String path) {
    return Version.fromJson(
      jsonDecode(File(join(path, "${basename(path)}.json")).readAsStringSync()),
    );
  }

  factory Game.fromJson(
    String librariesPath,
    String versionPath,
    Map<String, dynamic> json,
  ) {
    json.addAll({"librariesPath": librariesPath});
    json.addAll({"versionPath": versionPath});
    return _$GameFromJson(json);
  }

  Map<String, dynamic> toJson() => _$GameToJson(this);
}
