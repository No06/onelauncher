import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:one_launcher/utils/sys_info/sys_info.dart';

typedef MemoryStatusExFunc = Int32 Function(Pointer<NativeType>);
typedef MemoryStatusEx = int Function(Pointer<NativeType>);

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

abstract class Disposable {
  void dispose();
}

final class WindowsSysInfo extends SysInfo with Debounce {
  static const _libraryPath = 'kernel32.dll';
  static const _functionName = 'GlobalMemoryStatusEx';

  final Pointer<MEMORYSTATUSEX> _pointer = calloc<MEMORYSTATUSEX>()
    ..ref.dwLength = sizeOf<MEMORYSTATUSEX>();
  final _dylib = DynamicLibrary.open(_libraryPath);
  late final _status =
      _dylib.lookupFunction<MemoryStatusExFunc, MemoryStatusEx>(_functionName);

  @override
  int get totalPhyMem {
    freshInstance();
    return _pointer.ref.ullTotalPhys;
  }

  @override
  int get freePhyMem {
    freshInstance();
    return _pointer.ref.ullAvailPhys;
  }

  @override
  Pointer<NativeType> get pointer => _pointer;

  @override
  int Function(Pointer<NativeType> p1) get status => _status;
}
