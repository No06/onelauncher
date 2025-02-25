import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_launcher/app.dart';
import 'package:one_launcher/config/preference.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/window_state.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  await _init();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();

  Future<void> initWindow() async {
    await windowManager.ensureInitialized();
    const defaultWindowSize = Size(960, 593);
    final windowState = await WindowState.get();
    final windowSize = windowState?.size ?? defaultWindowSize;
    final position = windowState?.position;
    final hasPosition = position != null;
    final windowOptions = WindowOptions(
      center: !hasPosition,
      size: windowSize,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle:
          kHideTitleBar ? TitleBarStyle.hidden : TitleBarStyle.normal,
    );
    windowManager.addListener(WindowStateListener());
    return windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (hasPosition) await windowManager.setPosition(position);
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await Future.wait([
    JavaManager.init(),
    Preference.init(kAppName),
  ]);

  await initWindow();
}
