import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:one_launcher/utils/sys_info/sys_info.dart';

typedef MemoryStatusExFunc = Int32 Function(Pointer<MEMORYSTATUSEX>);
typedef MemoryStatusEx = int Function(Pointer<MEMORYSTATUSEX>);

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

final class WindowsSysInfo implements SysInfo {
  static const _libraryPath = 'kernel32.dll';
  static const _functionName = 'GlobalMemoryStatusEx';
  static const _debounce = 1000; // 1000ms

  final Pointer<MEMORYSTATUSEX> _arg = calloc<MEMORYSTATUSEX>()
    ..ref.dwLength = sizeOf<MEMORYSTATUSEX>();
  var _allowChange = true;

  void freshInstance() {
    if (!_allowChange) return;

    _allowChange = false;
    Future.delayed(const Duration(milliseconds: _debounce))
        .then((_) => _allowChange = true);

    final dylib = DynamicLibrary.open(_libraryPath);
    final memoryStatus = dylib.lookupFunction<
        Int32 Function(Pointer<NativeType>),
        int Function(Pointer<NativeType>)>(_functionName);

    if (memoryStatus(_arg) == 0) {
      final getLastError = DynamicLibrary.process()
          .lookupFunction<GetLastErrorFunc, GetLastError>('GetLastError');
      throw Exception("$runtimeType: Get sysinfo error: $getLastError");
    }
  }

  @override
  int get totalPhyMem {
    freshInstance();
    return _arg.ref.ullTotalPhys;
  }

  @override
  int get freePhyMem {
    freshInstance();
    return _arg.ref.ullAvailPhys;
  }
}
