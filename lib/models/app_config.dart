import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beacon/consts.dart';
import 'package:beacon/models/game_setting_config.dart';
import 'package:beacon/models/game_path_config.dart';
import 'package:beacon/models/theme_config.dart';
import 'package:beacon/models/account.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';

part 'app_config.g.dart';

final appConfig = AppConfig.instance;
const kDelimiter = "@";

@JsonSerializable()
final class AppConfig {
  AppConfig({
    AppThemeConfig? theme,
    List<GamePath>? paths,
    String? selectedAccount,
    List<Account>? accounts,
    GameSettingConfig? gameSetting,
  })  : theme = theme ?? AppThemeConfig(),
        _paths = RxList(paths ?? []),
        _selectedAccount =
            ValueNotifier(_selectedAccountFromJson(selectedAccount, accounts)),
        _accounts = RxList(accounts ?? []),
        gameSetting = gameSetting ?? GameSettingConfig(),
        super() {
    this.theme.addListener(save);
    _selectedAccount.addListener(save);
    this.gameSetting.addListener(save);
    everAll([_paths, _accounts], (_) => save());
  }

  AppThemeConfig theme;
  RxList<GamePath> _paths;
  ValueNotifier<Account?> _selectedAccount;
  RxList<Account> _accounts;
  GameSettingConfig gameSetting;

  List<GamePath> get paths => _paths;
  ValueNotifier<Account?> get selectedAccountNotifier => _selectedAccount;

  @JsonKey(toJson: _selectedAccounttoString)
  Account? get selectedAccount => _selectedAccount.value;
  set selectedAccount(Account? newVal) => _selectedAccount.value = newVal;
  static String? _selectedAccounttoString(Account? account) {
    final selectedAccount = account;
    if (selectedAccount == null) return null;

    return selectedAccount.type.name + kDelimiter + selectedAccount.uuid;
  }

  static Account? _selectedAccountFromJson(
      String? str, List<Account>? accounts) {
    if (str == null) return null;

    final parts = str.split(kDelimiter);
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

  List<Account> get accounts => _accounts;

  static AppConfig? _instance;

  static AppConfig get instance {
    if (_instance == null) {
      throw Exception('AppConfig is not initialized');
    }
    return _instance!;
  }

  static Future<String> _getConfigPath() async {
    return join((await kConfigPath).path, kConfigName);
  }

  static Future<void> init() async {
    final config = File(await _getConfigPath());
    final readString = await config.readAsString();
    var content = readString;
    if (!await config.exists() || readString.isEmpty) {
      await save();
      content = await config.readAsString();
    }
    _instance = AppConfig.fromJson(json.decode(content));
  }

  static Future<void> save([AppConfig? appConfig]) async {
    final config = File(await _getConfigPath());
    final json = const JsonEncoder.withIndent('  ').convert(
      appConfig ?? _instance ?? AppConfig().toJson(),
    );
    await config.writeAsString(json);
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigToJson(this);
}
