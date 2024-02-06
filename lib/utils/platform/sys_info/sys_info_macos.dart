import 'package:one_launcher/utils/platform/architecture.dart';
import 'package:one_launcher/utils/platform/sys_info/sys_info.dart';

class MacOSSysInfo implements SysInfo {
  @override
  // TODO: implement freePhyMem
  int get freePhyMem => throw UnimplementedError();

  @override
  // TODO: implement totalPhyMem
  int get totalPhyMem => throw UnimplementedError();

  @override
  // TODO: implement usedPhyMem
  int get usedPhyMem => throw UnimplementedError();

  @override
  // TODO: implement architecture
  Architecture get architecture => throw UnimplementedError();
}
