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

/// Minecraft 文件夹名
const kGameDirectoryName = '.minecraft';

/// 配置文件账号分隔符
const _kAccountDelimiter = "@";

/// 启动器配置文件
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

        /// 监听所有对象的变化，做到响应式
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

  /// [GetStorage] 持久化存储 Key
  static const _launcherGamePathBoxKey = "launcherGamePath";

  /// 配置文件存储目录
  static late final String _configPath;

  final AppThemeConfig theme;

  /// 记录游戏目录在List中的位置，持久化存储索引记录
  final RxList<int> _launcherGamePathIndexes;

  /// 游戏路径
  final RxSet<GamePath> _paths;

  /// 被选中的用户
  final ValueNotifier<Account?> _selectedAccount;

  /// 可用的用户集合
  final RxSet<Account> _accounts;

  /// 全局游戏设置配置文件
  final GameSettingConfig gameSetting;

  /// 启动器当前目录
  static final _currentGamePath = GamePath(
    name: "启动器目录",
    path:
        join(File(Platform.resolvedExecutable).parent.path, kGameDirectoryName),
  );

  /// 官方启动器目录
  static final _officialGamePath = GamePath(
    name: "官方启动器目录",
    path: _getOfficialPath,
  );

  /// 启动器目录
  static final launcherGamePaths = [_currentGamePath, _officialGamePath];

  /// 启动器目录索引
  @JsonKey(includeFromJson: false, includeToJson: false)
  RxList<int> get launcherGamePathIndexes => _launcherGamePathIndexes;

  /// 获取可用的游戏启动器目录
  /// 通过 [_launcherGamePathIndexes] 记录的索引值从 [GetStorage] 获取数据
  List<GamePath> get availableLauncherGamePaths => List.generate(
        _launcherGamePathIndexes.length,
        (index) => launcherGamePaths[_launcherGamePathIndexes[index]],
      );

  /// 获取官方启动器安装目录
  /// 以适应不同操作系统上的官方启动器路径
  static String get _getOfficialPath {
    try {
      // 环境变量
      final String env = Platform.isWindows ? 'APPDATA' : 'HOME';
      // 变量值
      final String? value = Platform.environment[env];
      if (value == null) {
        throw Exception("未找到环境变量 $env");
      }
      // Windows & Linux
      if (Platform.isWindows || Platform.isLinux) {
        return join(value, kGameDirectoryName);
      }
      // MacOS
      if (Platform.isMacOS) {
        return join(value, "Library", "Application Support", "minecraft");
      }
      throw Exception("不支持的系统类型 ${Platform.operatingSystem}");
    } catch (e) {
      return "unknown";
    }
  }

  /// 从 [availableLauncherGamePaths] 可用的启动器游戏路径再加上 [path] 存储的
  /// 手动添加的路径中执行 [GamePath.gamesOnVersion] 搜索游戏
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

  /// 用于 Json 初始化的静态函数
  static List _setToList(Set set) => set.toList();

  /// 响应式被选择的用户
  ValueNotifier<Account?> get selectedAccountNotifier => _selectedAccount;

  /// 获取被选择用户
  @JsonKey(toJson: _selectedAccountToString, includeIfNull: false)
  Account? get selectedAccount => _selectedAccount.value;

  set selectedAccount(Account? newVal) => _selectedAccount.value = newVal;

  /// 用于配置文件中 [selectedAccount] 被选择的用户序列化
  static String? _selectedAccountToString(Account? account) {
    final selectedAccount = account;
    if (selectedAccount == null) return null;

    return selectedAccount.type.name +
        _kAccountDelimiter +
        selectedAccount.uuid;
  }

  /// 用于配置文件中 [selectedAccount] 被选择的用户反序列化
  /// 传入 JsonString 和配置文件中存有的账号
  static Account? _selectedAccountFromJson(
    String? str,
    Set<Account>? accounts,
  ) {
    if (str == null) return null;

    // 用指定的分隔符 分隔成 用户类型 和 用户UUID 部分
    final parts = str.split(_kAccountDelimiter);
    final sType = parts[0];
    final sUuid = parts[1];

    // 反序列化成对象
    final type = AccountType.values.byName(sType);

    // 从已有账号中匹配并返回
    for (Account account in accounts ?? []) {
      if (account.type == type && account.uuid == sUuid) {
        return account;
      }
    }
    throw ErrorDescription("已有账号中未找到目标");
  }

  /// 静态存储 全局维护这一配置文件
  static AppConfig? _instance;

  static AppConfig get instance {
    if (_instance == null) {
      throw Exception('AppConfig is not initialized');
    }
    return _instance!;
  }

  /// 初始化配置文件存储的目录
  static Future<void> _initConfigPath() async {
    final configDirectory = Directory(await kConfigPath);
    await configDirectory.create();
    _configPath = join(configDirectory.path, kConfigName);
  }

  /// 初始化
  /// 通过 [_initConfigPath] 初始化后，获取 [_configPath] 路径的文件，将其转换成
  /// 配置文件 [AppConfig] 并赋值给 [_instance]
  static Future<void> init() async {
    // 初始化配置文件目录
    await _initConfigPath();
    final config = File(_configPath);

    // 如果文件不存在并且为空 则新建对象
    if (!await config.exists() || (await config.length()) == 0) {
      _instance = AppConfig();
      return;
    }
    // 将文件反序列化成配置文件
    final content = await config.readAsString();
    _instance = AppConfig.fromJson(json.decode(content));
  }

  /// 将静态维护的 [_instance] 保存至设备本地
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
