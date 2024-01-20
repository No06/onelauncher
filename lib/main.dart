import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:one_launcher/models/config/app_config.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:window_manager/window_manager.dart';

import 'app.dart';

late final PackageInfo appInfo;

void main() async {
  await init();
  runApp(const MyApp());
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  // debug 模式下擦除持久化数据
  // if (kDebugMode) {
  //   await GetStorage().erase();
  // }
  await Future.wait([
    PackageInfo.fromPlatform().then((value) => appInfo = value),
    JavaUtil.init(),
    windowManager.ensureInitialized(),
  ]);
  // 获取持久化配置文件
  await GetStorage.init().then(
    (value) => AppConfig.init(),
  );
  // 初始化窗口
  const defaultWindowWidth = 960.0;
  const defaultWindowHeight = 593.0;
  const windowSize = Size(defaultWindowWidth, defaultWindowHeight);
  final windowOptions = WindowOptions(
    size: windowSize,
    minimumSize: windowSize,
    center: false,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle:
        Platform.isWindows ? TitleBarStyle.hidden : TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAsFrameless();
  });
}
