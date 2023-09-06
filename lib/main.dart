import 'package:beacon/models/app_config.dart';
import 'package:beacon/utils/java_util.dart';
import 'package:flutter/material.dart';

import 'package:window_manager/window_manager.dart';

import 'app.dart';

void main() async {
  await init();
  runApp(const MyApp());
}

Future<void> init() async {
  await JavaUtil.init();
  await AppConfig.init();
  // 初始化窗口
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  const windowSize = Size(960, 593);
  WindowOptions windowOptions = const WindowOptions(
    size: windowSize,
    minimumSize: windowSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
