import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:one_launcher/models/app_config.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:window_manager/window_manager.dart';

import 'app.dart';

const kDefaultWindowWidth = 960.0;
const kDefaultWindowHeight = 593.0;

late final PackageInfo appInfo;

void main() async {
  await init();
  runApp(const MyApp());
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    Future(() async => appInfo = await PackageInfo.fromPlatform()),
    GetStorage.init(),
    JavaUtil.init(),
    AppConfig.init(),
    windowManager.ensureInitialized(),
  ]);
  print(GetStorage("filterRule").read<List>("gameTypes"));
  // 初始化窗口
  const windowSize = Size(kDefaultWindowWidth, kDefaultWindowHeight);
  final windowOptions = WindowOptions(
    size: windowSize,
    minimumSize: windowSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle:
        Platform.isWindows ? TitleBarStyle.hidden : TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
