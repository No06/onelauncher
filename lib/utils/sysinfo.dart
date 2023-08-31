import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

// 定义一个typedef来表示C函数的类型签名
typedef MemoryStatusExFunc = Int32 Function(Pointer<MEMORYSTATUSEX>);

// 定义一个typedef来表示Dart函数的类型签名
typedef MemoryStatusEx = int Function(Pointer<MEMORYSTATUSEX>);

// 定义一个typedef来表示C函数的类型签名
typedef GetLastErrorFunc = Int32 Function();

// 定义一个typedef来表示Dart函数的类型签名
typedef GetLastError = int Function();

const kMegaByte = 1024 * 1024;

// 定义一个类来表示C结构体MEMORYSTATUSEX
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

abstract final class SysInfo {
  /// totalPhyMem 物理内存
  /// freePhyMem 空闲物理内存
  static final int _totalPhyMem = getTotalPhyMem;
  static int _freePhyMem = getTotalPhyMem;

  static bool _allowChange = true;

  static set freePhyMem(int value) => freePhyMem = value;

  static int get totalPhyMem => _totalPhyMem;
  static int get freePhyMem {
    if (_allowChange) {
      _allowChange = false;
      Timer(const Duration(seconds: 1), () => _allowChange = true);
      _freePhyMem = getFreePhyMem;
    }
    return _freePhyMem;
  }

  static int get getFreePhyMem {
    late final Pointer<NativeType> arg;
    late final String libraryPath;
    late final String functionName;
    if (Platform.isWindows) {
      arg = calloc<MEMORYSTATUSEX>();
      libraryPath = 'kernel32.dll';
      functionName = 'GlobalMemoryStatusEx';
      (arg as Pointer<MEMORYSTATUSEX>).ref.dwLength = sizeOf<MEMORYSTATUSEX>();
    } else {
      arg = calloc<Int64>();
      functionName = 'sysconf';
      if (Platform.isLinux) {
        libraryPath = 'libc.so.6';
        (arg as Pointer<Int64>).value = 29;
      } else {
        libraryPath = 'libSystem.dylib';
        (arg as Pointer<Int64>).value = 1;
      }
    }

    final dylib = DynamicLibrary.open(libraryPath);
    final memoryStatus = dylib.lookupFunction<
        Int32 Function(Pointer<NativeType>),
        int Function(Pointer<NativeType>)>(functionName);
    final result = memoryStatus(arg);

    if (result == 0) {
      // 获取对C函数的引用，并放入一个变量中
      final getLastError = DynamicLibrary.process()
          .lookupFunction<GetLastErrorFunc, GetLastError>('GetLastError');

      print('Error: $getLastError');
      return 0;
    }

    if (Platform.isWindows) {
      return (arg as Pointer<MEMORYSTATUSEX>).ref.ullAvailPhys;
    } else if (Platform.isLinux || Platform.isMacOS) {
      final pageSize =
          dylib.lookupFunction<Int64 Function(Int64), int Function(int)>(
              'sysconf')(30); // _SC_PAGE_SIZE
      return result * pageSize;
    }
    return 0;
  }

  static int get getTotalPhyMem {
    late final Pointer<NativeType> arg;
    late final String libraryPath;
    late final String functionName;
    if (Platform.isWindows) {
      arg = calloc<MEMORYSTATUSEX>();
      libraryPath = 'kernel32.dll';
      functionName = 'GlobalMemoryStatusEx';
      (arg as Pointer<MEMORYSTATUSEX>).ref.dwLength = sizeOf<MEMORYSTATUSEX>();
    } else {
      arg = calloc<Int64>();
      functionName = 'sysconf';
      if (Platform.isLinux) {
        libraryPath = 'libc.so.6';
        (arg as Pointer<Int64>).value = 30;
      } else {
        libraryPath = 'libSystem.dylib';
        (arg as Pointer<Int64>).value = 2;
      }
    }

    final dylib = DynamicLibrary.open(libraryPath);
    final memoryStatus = dylib.lookupFunction<
        Int32 Function(Pointer<NativeType>),
        int Function(Pointer<NativeType>)>(functionName);
    final result = memoryStatus(arg);

    if (result == 0) {
      // 获取对C函数的引用，并放入一个变量中
      final getLastError = DynamicLibrary.process()
          .lookupFunction<GetLastErrorFunc, GetLastError>('GetLastError');

      print('Error: $getLastError');
      return 0;
    }

    if (Platform.isWindows) {
      return (arg as Pointer<MEMORYSTATUSEX>).ref.ullTotalPhys;
    } else if (Platform.isLinux || Platform.isMacOS) {
      final pageSize =
          dylib.lookupFunction<Int64 Function(Int64), int Function(int)>(
              'sysconf')(30);
      // _SC_PAGE_SIZE
      return result * pageSize;
    }
    return 0;
  }
}
