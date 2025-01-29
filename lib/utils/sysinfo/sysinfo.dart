import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:one_launcher/utils/sysinfo/os_architecture.dart';
import 'package:stdlibc/stdlibc.dart' as libc;
import 'package:win32/win32.dart';

Sysinfo get sysinfo {
  if (Platform.isLinux || Platform.isMacOS) return LibCSysinfo._();
  if (Platform.isWindows) return Win32Sysinfo._();
  throw UnimplementedError('Unknown system: ${Platform.operatingSystem}');
}

abstract class Sysinfo {
  static final _osArchitecture = switch (sizeOf<Pointer<Void>>()) {
    4 => OsArchitecture.bit32,
    8 => OsArchitecture.bit64,
    _ => OsArchitecture.unknown,
  };

  OsArchitecture get osArchitecture => _osArchitecture;

  int get totalPhyMem;

  int get freePhyMem;

  int get usedPhyMem => totalPhyMem - freePhyMem;
}

class LibCSysinfo extends Sysinfo {
  LibCSysinfo._();

  final _sysinfo = () {
    final instance = libc.sysinfo();
    assert(instance != null, 'sysinfo failed');
    return instance!;
  }();

  @override
  int get freePhyMem => _sysinfo.freeram;

  @override
  int get totalPhyMem => _sysinfo.totalram;
}

class Win32Sysinfo extends Sysinfo {
  Win32Sysinfo._() {
    final memoryStatePtr = calloc<MEMORYSTATUSEX>()
      ..ref.dwLength = sizeOf<MEMORYSTATUSEX>();
    final result = GlobalMemoryStatusEx(memoryStatePtr);
    if (result != 1) {
      throw Exception('error code: $result');
    }
    _freePhyMem = memoryStatePtr.ref.ullAvailPhys;
    _totalPhyMem = memoryStatePtr.ref.ullTotalPhys;
    free(memoryStatePtr);
  }

  late final int _freePhyMem;
  @override
  int get freePhyMem => _freePhyMem;

  late final int _totalPhyMem;
  @override
  int get totalPhyMem => _totalPhyMem;
}
