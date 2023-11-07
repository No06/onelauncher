import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/models/game_setting_config.dart';
import 'package:one_launcher/models/game_path_config.dart';
import 'package:one_launcher/models/theme_config.dart';
import 'package:one_launcher/models/account/account.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';

part 'app_config.g.dart';

AppConfig get appConfig => AppConfig.instance;
const kGameDirectoryName = '.minecraft';
const _kAccountDelimiter = "@";

@JsonSerializable()
final class AppConfig extends ChangeNotifier {
  AppConfig({
    AppThemeConfig? theme,
    Set<GamePath>? paths,
    String? selectedAccount,
    Set<Account>? accounts,
    GameSettingConfig? gameSetting,
  })  : theme = theme ?? AppThemeConfig(),
        _launcherGamePathIndexes = RxList.from(GetStorage()
                .read<List>(_launcherGamePathBoxKey)
                ?.map((e) => e as int) ??
            List.generate(launcherGamePaths.length, (index) => index)),
        _paths = RxSet(paths ?? {}),
        _selectedAccount =
            ValueNotifier(_selectedAccountFromJson(selectedAccount, accounts)),
        _accounts = RxSet(accounts ?? {}),
        gameSetting = gameSetting ?? GameSettingConfig(),
        super() {
    this.theme.addListener(notifyListeners);
    ever(
      _launcherGamePathIndexes,
      (callback) => GetStorage().write(
        _launcherGamePathBoxKey,
        callback,
      ),
    );
    for (var path in _paths) {
      path.addListener(notifyListeners);
    }
    _selectedAccount.addListener(notifyListeners);
    this.gameSetting.addListener(notifyListeners);
    everAll([_paths, _accounts], (_) => notifyListeners());
  }
  static const _launcherGamePathBoxKey = "launcherGamePath";
  static late final String _configPath;

  final AppThemeConfig theme;
  // 持久化存储索引
  final RxList<int> _launcherGamePathIndexes;
  final RxSet<GamePath> _paths;
  final ValueNotifier<Account?> _selectedAccount;
  final RxSet<Account> _accounts;
  final GameSettingConfig gameSetting;

  static final _currentGamePath = GamePath(
    name: "启动器目录",
    path:
        join(File(Platform.resolvedExecutable).parent.path, kGameDirectoryName),
  );
  static final _officialGamePath = GamePath(
    name: "官方启动器目录",
    path: _getOfficialPath,
  );
  static final launcherGamePaths = [_currentGamePath, _officialGamePath];

  @JsonKey(includeFromJson: false, includeToJson: false)
  RxList<int> get launcherGamePathIndexes => _launcherGamePathIndexes;

  List<GamePath> get availableLauncherGamePaths => List.generate(
        _launcherGamePathIndexes.length,
        (index) => launcherGamePaths[_launcherGamePathIndexes[index]],
      );

  static String get _getOfficialPath {
    try {
      final String env = Platform.isWindows ? 'APPDATA' : 'HOME';
      final String? value = Platform.environment[env];
      if (value == null) {
        throw Exception("未找到环境变量 $env");
      }
      if (Platform.isWindows || Platform.isLinux) {
        return join(value, kGameDirectoryName);
      }
      if (Platform.isMacOS) {
        return join(value, "Library", "Application Support", "minecraft");
      }
      throw Exception("不支持的系统类型 ${Platform.operatingSystem}");
    } catch (e) {
      return "unknown";
    }
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  Future<List<Game>> get gamesOnPaths async {
    final gameList = await Future.wait(
      availableLauncherGamePaths
          .map((path) => path.gamesOnVersion)
          .followedBy(_paths.map((path) => path.gamesOnVersion)),
    );
    return List.from(gameList.expand((list) => list));
  }

  @JsonKey(toJson: _setToList)
  RxSet<GamePath> get paths => _paths;
  @JsonKey(toJson: _setToList)
  RxSet<Account> get accounts => _accounts;

  static List _setToList(Set set) => set.toList();

  ValueNotifier<Account?> get selectedAccountNotifier => _selectedAccount;
  @JsonKey(toJson: _selectedAccounttoString, includeIfNull: false)
  Account? get selectedAccount => _selectedAccount.value;
  set selectedAccount(Account? newVal) => _selectedAccount.value = newVal;
  static String? _selectedAccounttoString(Account? account) {
    final selectedAccount = account;
    if (selectedAccount == null) return null;

    return selectedAccount.type.name +
        _kAccountDelimiter +
        selectedAccount.uuid;
  }

  static Account? _selectedAccountFromJson(
      String? str, Set<Account>? accounts) {
    if (str == null) return null;

    final parts = str.split(_kAccountDelimiter);
    final sType = parts[0];
    final sUuid = parts[1];
    for (AccountType type in AccountType.values) {
      if (type.name == sType) {
        for (Account account in accounts ?? []) {
          if (account.type == type && account.uuid == sUuid) {
            return account;
          }
        }
        throw Exception("已有账号中未找到目标");
      }
    }
    throw Exception("未知的账号类型");
  }

  static AppConfig? _instance;

  static AppConfig get instance {
    if (_instance == null) {
      throw Exception('AppConfig is not initialized');
    }
    return _instance!;
  }

  static Future<void> _initConfigPath() async {
    final configDirectory = Directory(await kConfigPath);
    await configDirectory.create();
    _configPath = join(configDirectory.path, kConfigName);
  }

  static Future<void> init() async {
    await _initConfigPath();
    final config = File(_configPath);
    if (!await config.exists() || (await config.length()) == 0) {
      _instance = AppConfig();
      return;
    }
    final content = await config.readAsString();
    _instance = AppConfig.fromJson(json.decode(content));
  }

  Future<void> save([AppConfig? appConfig]) async {
    final config = File(_configPath);
    final json = const JsonEncoder.withIndent('  ').convert(
      appConfig ?? _instance ?? AppConfig().toJson(),
    );
    await config.writeAsString(json);
  }

  @override
  void notifyListeners() {
    save();
    super.notifyListeners();
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigToJson(this);
}
