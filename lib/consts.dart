import 'package:beacon/models/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

const kMegaByte = 1024 * 1024;

const kConfigName = "beacon.json";
final kConfigPath = getApplicationDocumentsDirectory();

const kDefaultThemeMode = ThemeMode.system;
const kDefaultSeedColor = SeedColor.blue;

final kBorderRadius = BorderRadius.circular(7.5);
final kMediaBorderRadius = BorderRadius.circular(10);
final kLagerBorderRadius = BorderRadius.circular(12.5);
