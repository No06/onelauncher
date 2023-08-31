import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '/utils/game/java.dart';
import 'controller/storage.dart';
import 'app.dart';

void main() async {
  init();
  runApp(const MyApp());
}

Future<void> init() async {
  Get.put(ConfigController(), permanent: true);
  Javas.init();
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
