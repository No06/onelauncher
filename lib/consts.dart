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

const kDefaultBorderRadius = BorderRadius.all(Radius.circular(7.5));
const kMediaBorderRadius = BorderRadius.all(Radius.circular(10));
const kLagerBorderRadius = BorderRadius.all(Radius.circular(12.5));
