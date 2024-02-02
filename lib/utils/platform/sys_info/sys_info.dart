import 'dart:ffi';
import 'dart:io';

import 'package:one_launcher/utils/platform/architecture.dart';
import 'package:one_launcher/utils/platform/processor_architecture.dart';
import 'package:one_launcher/utils/platform/sys_info/sys_info_linux.dart';
import 'package:one_launcher/utils/platform/sys_info/sys_info_macos.dart';
import 'package:one_launcher/utils/platform/sys_info/sys_info_windows.dart';

typedef GetLastErrorFunc = Int32 Function();
typedef GetLastError = int Function();

SysInfo get sysinfo => SysInfo.instance;

abstract class SysInfo {
  Pointer<NativeType> get pointer;
  int Function(Pointer<NativeType>) get status;

  /// 处理器架构
  ProcessorArchitecture get processorArchitecture;

  /// 系统架构
  Architecture get architecture => processorArchitecture.architecture;

  static final instance = Platform.isWindows
      ? WindowsSysInfo()
      : Platform.isLinux
          ? LinuxSysInfo()
          : Platform.isMacOS
              ? MacOSSysInfo()
              : throw Exception("Unknown Platform System");

  int get totalPhyMem;
  int get freePhyMem;
  int get usedPhyMem => totalPhyMem - freePhyMem;
}

/// 用于混入 [SysInfo] 的防抖代码块
mixin Debounce on SysInfo {
  static const _debounce = 1000; // 1000ms
  var _allowChange = true;

  void freshInstance() {
    if (!_allowChange) return;

    _allowChange = false;
    Future.delayed(const Duration(milliseconds: _debounce))
        .then((_) => _allowChange = true);

    if (status(pointer) == 0) {
      final getLastError = DynamicLibrary.process()
          .lookupFunction<GetLastErrorFunc, GetLastError>('GetLastError');
      throw Exception("$runtimeType: Get sysinfo error: $getLastError");
    }
  }
}

extension Data<T> on num {
  double toKB() => this / 1024;
  double toMB() => toKB() / 1024;
  double toGB() => toMB() / 1024;
}
