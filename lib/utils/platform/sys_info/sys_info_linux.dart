// 表示一个指向sysinfo结构体的指针
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:one_launcher/utils/platform/processor_architecture.dart';
import 'package:one_launcher/utils/platform/sys_info/sys_info.dart';

// 定义一个C语言的sysinfo函数类型
typedef SysInfoFunc = Int32 Function(Pointer<NativeType> info);

// 定义一个dart语言的sysinfo函数类型
typedef SysInfoDart = int Function(Pointer<NativeType> info);

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

final class LinuxSysInfo extends SysInfo with Debounce {
  final Pointer<SYSINFO> _info = calloc<SYSINFO>();
  final Pointer<NativeFunction<SysInfoFunc>> _pointer =
      DynamicLibrary.process().lookup('sysinfo');
  late final SysInfoDart _status = _pointer.asFunction<SysInfoDart>();

  @override
  int get freePhyMem {
    freshInstance();
    return _info.ref.freeram;
  }

  @override
  int get totalPhyMem {
    freshInstance();
    return _info.ref.totalram;
  }

  @override
  Pointer<NativeType> get pointer => _pointer;

  @override
  int Function(Pointer<NativeType> p1) get status => _status;

  @override
  // TODO: implement processorArchitecture
  ProcessorArchitecture get processorArchitecture => throw UnimplementedError();
}
