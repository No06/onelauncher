import 'dart:ffi';

import 'package:one_launcher/utils/sys_info/sys_info.dart';

class MacOSSysInfo implements SysInfo {
  @override
  // TODO: implement freePhyMem
  int get freePhyMem => throw UnimplementedError();

  @override
  // TODO: implement totalPhyMem
  int get totalPhyMem => throw UnimplementedError();

  @override
  // TODO: implement pointer
  Pointer<NativeType> get pointer => throw UnimplementedError();

  @override
  // TODO: implement status
  int Function(Pointer<NativeType> p1) get status => throw UnimplementedError();
}
