import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:one_launcher/utils/platform/architecture.dart';
import 'package:one_launcher/utils/platform/processor_architecture.dart';
import 'package:one_launcher/utils/platform/sys_info/sys_info.dart';

typedef MemoryStatusExFunc = Int32 Function(Pointer<NativeType>);
typedef MemoryStatusEx = int Function(Pointer<NativeType>);

// 定义 SYSTEM_INFO 结构体，用于接收 GetSystemInfo 函数的返回值
// 参考 https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-system_info
final class MEMORYSTATUSEX extends Struct {
  @Uint32()
  external int dwLength;

  @Uint32()
  external int dwMemoryLoad;

  @Uint64()
  external int ullTotalPhys;

  @Uint64()
  external int ullAvailPhys;

  @Uint64()
  external int ullTotalPageFile;

  @Uint64()
  external int ullAvailPageFile;

  @Uint64()
  external int ullTotalVirtual;

  @Uint64()
  external int ullAvailVirtual;

  @Uint64()
  external int ullAvailExtendedVirtual;
}

// 定义 GetSystemInfo 函数的类型，参考 https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-getsysteminfo
typedef GetSystemInfoC = Void Function(Pointer<SYSTEMINFO>);
typedef GetSystemInfoDart = void Function(Pointer<SYSTEMINFO>);

// 定义 SYSTEM_INFO 结构体，用于接收 GetSystemInfo 函数的返回值
// 参考 https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-system_info
final class SYSTEMINFO extends Struct {
  @Uint16()
  external int wProcessorArchitecture; // 系统架构，0 表示 x86，9 表示 x64，其他值参考文档

  @Uint16()
  external int wReserved;

  @Uint32()
  external int dwPageSize;

  external Pointer<Void> lpMinimumApplicationAddress;

  external Pointer<Void> lpMaximumApplicationAddress;

  external Pointer<Void> dwActiveProcessorMask;

  @Uint32()
  external int dwNumberOfProcessors;

  @Uint32()
  external int dwProcessorType;

  @Uint32()
  external int dwAllocationGranularity;

  @Uint16()
  external int wProcessorLevel;

  @Uint16()
  external int wProcessorRevision;
}

final class WindowsSysInfo extends SysInfo {
  static const _kernel32DylibName = 'kernel32.dll';
  static const _memoryStatusFuncName = 'GlobalMemoryStatusEx';
  static const _systemInfoFuncName = 'GetSystemInfo';

  // 指针
  final Pointer<MEMORYSTATUSEX> _memoryStatePointer = calloc<MEMORYSTATUSEX>()
    ..ref.dwLength = sizeOf<MEMORYSTATUSEX>();
  final _systemInfoPointer = calloc<SYSTEMINFO>();

  // 加载dll
  final _kernel32 = DynamicLibrary.open(_kernel32DylibName);

  // 函数
  late final _memoryStateFunc =
      _kernel32.lookupFunction<MemoryStatusExFunc, MemoryStatusEx>(
          _memoryStatusFuncName);
  late final _systemInfoFunc = _kernel32
      .lookupFunction<GetSystemInfoC, GetSystemInfoDart>(_systemInfoFuncName);

  Pointer<MEMORYSTATUSEX> _getMemoryState() {
    if (_memoryStateFunc(_memoryStatePointer) == 0) getLastError(this);
    return _memoryStatePointer;
  }

  @override
  int get totalPhyMem => _getMemoryState().ref.ullTotalPhys;

  @override
  int get freePhyMem => _getMemoryState().ref.ullAvailPhys;

  ProcessorArchitecture get processorArchitecture {
    // 调用 GetSystemInfo 函数，将结果写入 systemInfo 指针指向的内存
    _systemInfoFunc(_systemInfoPointer);

    switch (_systemInfoPointer.ref.wProcessorArchitecture) {
      case 9:
        return ProcessorArchitecture.amd64;
      case 5:
        return ProcessorArchitecture.arm;
      case 12:
        return ProcessorArchitecture.arm64;
      case 6:
        return ProcessorArchitecture.ia64;
      case 0:
        return ProcessorArchitecture.intel;
      default:
        return ProcessorArchitecture.unknown;
    }
  }

  @override
  Architecture get architecture => processorArchitecture.architecture;
}
