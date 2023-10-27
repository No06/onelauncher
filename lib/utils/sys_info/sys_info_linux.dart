// 表示一个指向sysinfo结构体的指针
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:one_launcher/utils/sys_info/sys_info.dart';

// 定义一个C语言的sysinfo函数类型
typedef SysInfoFunc = Int32 Function(Pointer<SYSINFO> info);

// 定义一个dart语言的sysinfo函数类型
typedef SysInfoDart = int Function(Pointer<SYSINFO> info);

// 表示一个sysinfo结构体
final class SYSINFO extends Struct {
  @Uint64()
  external int uptime; // Seconds since boot

  @Uint64()
  external int loads1; // 1 minute load averages

  @Uint64()
  external int loads5; // 5 minute load averages

  @Uint64()
  external int loads15; // 15 minute load averages

  @Uint64()
  external int totalram; // Total usable main memory size

  @Uint64()
  external int freeram; // Available memory size

  @Uint64()
  external int sharedram; // Amount of shared memory

  @Uint64()
  external int bufferram; // Memory used by buffers

  @Uint64()
  external int totalswap; // Total swap space size

  @Uint64()
  external int freeswap; // Swap space still available

  @Uint16()
  external int procs; // Number of current processes

  @Uint16()
  external int pad; // Padding for alignment

  @Uint64()
  external int totalhigh; // Total high memory size

  @Uint64()
  external int freehigh; // Available high memory size

  @Uint32()
  external int memUnit; // Memory unit size in bytes
}

final class LinuxSysInfo implements SysInfo {
  static const _debounce = 1000; // 1000ms
  var _allowChange = true;

  final Pointer<SYSINFO> info = calloc<SYSINFO>();

  late final Pointer<NativeFunction<SysInfoFunc>> sysinfoPointer =
      DynamicLibrary.process().lookup('sysinfo');
  late final SysInfoDart sysinfo = sysinfoPointer.asFunction<SysInfoDart>();

  void freshInstance() {
    if (!_allowChange) return;

    _allowChange = false;
    Future.delayed(const Duration(milliseconds: _debounce))
        .then((_) => _allowChange = true);

    if (sysinfo(info) != 0) {
      final getLastError = DynamicLibrary.process()
          .lookupFunction<GetLastErrorFunc, GetLastError>('GetLastError');
      throw Exception("$runtimeType: Get sysinfo error: $getLastError");
    }
  }

  @override
  int get freePhyMem {
    freshInstance();
    return info.ref.freeram;
  }

  @override
  int get totalPhyMem {
    freshInstance();
    return info.ref.totalram;
  }
}
