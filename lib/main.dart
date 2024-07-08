import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:flutter/material.dart';

import 'package:window_manager/window_manager.dart';

import 'app.dart';

final storage = GetStorage("$appName/config");

void main() async {
  await init();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();

  initWindow() async {
    await windowManager.ensureInitialized();
    const defaultWindowWidth = 960.0;
    const defaultWindowHeight = 593.0;
    const windowSize = Size(defaultWindowWidth, defaultWindowHeight);
    final windowOptions = WindowOptions(
      size: windowSize,
      minimumSize: windowSize,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle:
          Platform.isWindows ? TitleBarStyle.hidden : TitleBarStyle.normal,
    );
    return windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setAsFrameless();
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await Future.wait([
    JavaManager.init(),
    initWindow(),
    storage.initStorage,
  ]);
}
