import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';
import 'package:one_launcher/utils/platform/architecture.dart';
import 'package:one_launcher/utils/platform/sys_info/sys_info.dart';

// 定义一个C语言的sysinfo函数类型
typedef _SysInfoFunc = Int32 Function(Pointer<NativeType> info);

// 定义一个dart语言的sysinfo函数类型
typedef _SysInfoDart = int Function(Pointer<NativeType> info);

// 表示一个sysinfo结构体
final class _SYSINFO extends Struct {
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

// 定义一个函数类型，用于表示uname函数的签名
typedef _UnameFunc = Int32 Function(Pointer<_Utsname>);
typedef _UnameDart = int Function(Pointer<_Utsname>);

// 定义一个结构体，用于存储uname函数返回的信息
final class _Utsname extends Struct {
  // 每个字段都是一个指向以null结尾的字符串的指针
  @Int64()
  external int sysname;

  @Int64()
  external int nodename;

  @Int64()
  external int release;

  @Int64()
  external int version;

  @Int64()
  external int machine;

  @Int64()
  external int domainname;
}

// 定义一个结构体，用于表示sysctl函数的参数
final class _Sysctl extends Struct {
  // 名字数组的指针
  @Uint64()
  external int name;
  // 名字数组的长度
  @Uint32()
  external int namelen;
  // 值缓冲区的指针
  @Uint64()
  external int oldp;
  // 值缓冲区的长度的指针
  @Uint64()
  external int oldlenp;
  // 新值的指针
  @Uint64()
  external int newp;
  // 新值的长度
  @Uint64()
  external int newlen;
}

// 定义一个函数类型，用于表示sysctl函数的签名
typedef _SysctlFunc = Int32 Function(Pointer<_Sysctl> args);
// 定义一个函数类型，用于表示dart中调用sysctl函数的方式
typedef _SysctlDart = int Function(Pointer<_Sysctl> args);

final class LinuxSysInfo extends SysInfo {
  // 分配指针
  final _sysinfoPointer = calloc<_SYSINFO>();
  final _utsnamePointer = calloc<_Utsname>();

  // 定义 sysinfo 函数
  final _sysinfo = DynamicLibrary.open('sysinfo')
      .lookupFunction<_SysInfoFunc, _SysInfoDart>('getauxval');

  // 加载 uname 函数
  final _uname = DynamicLibrary.open('libc.so.6')
      .lookupFunction<_UnameFunc, _UnameDart>('uname');

  // 定义 sysctl 函数
  // 定义一个常量，表示硬件相关参数的名字
  static const _ctlHW = 6;
  // 定义一个常量，表示系统位宽的名字
  static const _hwWordSize = 8;
  // 加载 sysctl 函数
  final _sysctl = DynamicLibrary.open('libc.so.6')
      .lookupFunction<_SysctlFunc, _SysctlDart>('sysctl');
  // 分配一块内存，用于存储名字数组
  final _sysctlName = calloc<Int32>(2) + _ctlHW + _hwWordSize;
  // 分配一块内存，用于存储值缓冲区的长度
  final _oldlenp = calloc<Uint64>()..value = 8;
  // 分配一块内存，用于存储值缓冲区
  final _oldp = calloc<Uint64>();
  // 分配一块内存，用于存储sysctl函数的参数
  late final _sysctlArgs = calloc<_Sysctl>()
    ..ref.name = _sysctlName.address
    ..ref.namelen = 2
    ..ref.oldlenp = _oldlenp.address
    ..ref.newp = nullptr.address
    ..ref.newlen = 0;

  Pointer<_SYSINFO> _sysinfoGetFunc() {
    if (_sysinfo(_sysinfoPointer) == 0) getLastError(this);
    return _sysinfoPointer;
  }

  @override
  int get freePhyMem => _sysinfoGetFunc().ref.freeram;

  @override
  int get totalPhyMem => _sysinfoGetFunc().ref.totalram;

  @override
  Architecture get architecture {
    if (_sysctl(_sysctlArgs) != 0) getLastError(this);
    switch (_oldp.value) {
      case 32:
        return Architecture.x32;
      case 64:
        return Architecture.x64;
      default:
        "Unknow architechure value: ${_oldp.value}".printError();
        return Architecture.unknown;
    }
  }

  /// 调用 uname 返回机器架构
  /// 如：x86_64, i386, aarch64
  String get machine {
    if (_uname(_utsnamePointer) != 0) {
      final getLastError = DynamicLibrary.process()
          .lookupFunction<GetLastErrorFunc, GetLastError>('GetLastError');
      throw Exception("$runtimeType: Get sysinfo error: $getLastError");
    }
    final machinePtr = Pointer<Utf8>.fromAddress(_utsnamePointer.ref.machine);
    return machinePtr.toDartString();
  }
}
