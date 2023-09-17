import 'package:one_launcher/models/app_config.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:flutter/material.dart';

import 'package:window_manager/window_manager.dart';

import 'app.dart';

const kDefaultWindowWidth = 960.0;
const kDefaultWindowHeight = 593.0;

void main() async {
  await init();
  runApp(const MyApp());
}

Future<void> init() async {
  await Future.wait([
    JavaUtil.init(),
    AppConfig.init(),
  ]);
  // 初始化窗口
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  const windowSize = Size(kDefaultWindowWidth, kDefaultWindowHeight);
  const windowOptions = WindowOptions(
    size: windowSize,
    minimumSize: windowSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
