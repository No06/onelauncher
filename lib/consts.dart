import 'package:one_launcher/main.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const appName = "OneLauncher";
const kConfigName = "config.json";
final kGameConfigName = "${appInfo.appName}.json";
final kConfigDirectoryName = appInfo.appName;
final kConfigPath = Future(() async => join(
    (await getApplicationDocumentsDirectory()).path, kConfigDirectoryName));

final kDefaultBorderRadius = BorderRadius.circular(7.5);
final kMediaBorderRadius = BorderRadius.circular(10);
final kLagerBorderRadius = BorderRadius.circular(12.5);

const kMouseScrollAnimationCurve = Curves.fastEaseInToSlowEaseOut;
