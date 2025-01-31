import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:one_launcher/utils/sysinfo/os_architecture.dart';
import 'package:stdlibc/stdlibc.dart' as libc;
import 'package:win32/win32.dart';

class Sysinfo {
  factory Sysinfo() {
    if (Platform.isLinux || Platform.isMacOS) {
      final info = libc.sysinfo();
      if (info == null) {
        throw Exception('sysinfo failed');
      }
      return Sysinfo._(
        totalPhyMem: info.totalram,
        freePhyMem: info.freeram,
      );
    }
    if (Platform.isWindows) {
      final memoryStatePtr = calloc<MEMORYSTATUSEX>()
        ..ref.dwLength = sizeOf<MEMORYSTATUSEX>();
      final result = GlobalMemoryStatusEx(memoryStatePtr);
      free(memoryStatePtr);
      if (result != 1) {
        throw Exception('error code: $result');
      }
      final ref = memoryStatePtr.ref;
      return Sysinfo._(
        totalPhyMem: ref.ullTotalPhys,
        freePhyMem: ref.ullAvailPhys,
      );
    }
    throw UnimplementedError('Unknown system: ${Platform.operatingSystem}');
  }

  const Sysinfo._({required this.totalPhyMem, required this.freePhyMem})
      : assert(totalPhyMem >= freePhyMem, 'Invalid memory size');

  static final osArchitecture = switch (sizeOf<Pointer<Void>>()) {
    4 => OsArchitecture.bit32,
    8 => OsArchitecture.bit64,
    _ => OsArchitecture.unknown,
  };

  final int totalPhyMem;

  final int freePhyMem;

  int get usedPhyMem => totalPhyMem - freePhyMem;
}
