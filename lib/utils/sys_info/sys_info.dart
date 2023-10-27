import 'dart:ffi';

typedef GetLastErrorFunc = Int32 Function();
typedef GetLastError = int Function();

abstract class SysInfo {
  int get totalPhyMem;
  int get freePhyMem;
}
