import 'dart:ffi';

typedef GetLastErrorFunc = Int32 Function();
typedef GetLastError = int Function();

abstract class SysInfo {
  Pointer<NativeType> get pointer;
  int Function(Pointer<NativeType>) get status;

  int get totalPhyMem;
  int get freePhyMem;
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
