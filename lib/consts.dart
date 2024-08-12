import 'dart:io';

import 'package:flutter/material.dart';

const kAppName = "OneLauncher";
final kGameDirectoryName = Platform.isWindows ? ".minecraft" : "minecraft";
final kHideTitleBar = Platform.isWindows;
const kClientId = "8b6fb1f0-7e3e-41d3-8171-53ff17134e00";
const kMinecraftClientId = "00000000402b5328"; // Minecraft Client Id

const kDefaultBorderRadius = BorderRadius.all(Radius.circular(7.5));
const kMediaBorderRadius = BorderRadius.all(Radius.circular(10));
const kLagerBorderRadius = BorderRadius.all(Radius.circular(12.5));
