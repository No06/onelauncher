import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:beacon/theme.dart';
import 'package:beacon/utils/game/game_setting.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/game/path.dart';

class ConfigController extends GetxController with StateMixin {
  late Map<String, dynamic> _jsonData;
  Directory? _jsonPath;

  Future<Directory> get jsonPath async =>
      _jsonPath ??= await getApplicationDocumentsDirectory();

  AppTheme? _appTheme;
  GameSetting? _gameSetting;
  List<GamePath> _paths = GamePath.paths;

  AppTheme get appTheme => _appTheme!;
  GameSetting get gameSetting => _gameSetting!;
  List<GamePath> get pathSetting => _paths;

  Map<String, dynamic> createJsonData({
    AppTheme? appTheme,
    GameSetting? gameSetting,
    List<GamePath>? paths,
    Map<String, dynamic>? jsonData,
  }) {
    return {
      'theme': appTheme ??
          (jsonData == null
              ? AppTheme()
              : AppTheme.fromJson(jsonData['theme'])),
      'paths': paths ??
          (jsonData == null
              ? GamePath.toJsonList()
              : GamePath.fromJsonList(jsonData['paths'])),
      'globalGameSettings': gameSetting ??
          (jsonData == null
              ? GameSetting()
              : GameSetting.fromJson(jsonData['globalGameSettings'])),
    };
  }

  Future<String> getConfigPath() async {
    final directory = await jsonPath;
    const fileName = "beacon.json";
    return join(directory.path, fileName);
  }

  Future<void> readConfig() async {
    final file = File(await getConfigPath());
    if (!await file.exists() || (await file.readAsString()).isEmpty) {
      await createConfig();
      print("LauncherConfig: '${file.path}' is not found or empty!");
    }
    final contents = await file.readAsString();
    _jsonData = json.decode(
        json.encode(createJsonData(jsonData: await json.decode(contents))));
  }

  Future<void> createConfig() async {
    final path = await getConfigPath();
    final file = File(path);
    _jsonData = createJsonData(
      appTheme: _appTheme,
      gameSetting: _gameSetting,
      paths: _paths,
    );
    final data = const JsonEncoder.withIndent('  ').convert(_jsonData);
    await file.writeAsString(data);
  }

  void updateConfig([List<String>? tag]) {
    createConfig();
    update(tag);
  }

  @override
  void onInit() async {
    super.onInit();
    change(null, status: RxStatus.loading());
    await readConfig();
    _appTheme = AppTheme.fromJson(_jsonData['theme']);
    _gameSetting = GameSetting.fromJson(_jsonData['globalGameSettings']);
    _paths = GamePath.fromJsonList(_jsonData['paths']);
    change(_jsonData, status: RxStatus.success());
  }
}
