import 'package:one_launcher/utils/platform/architecture.dart';

enum ProcessorArchitecture {
  amd64(Architecture.x64), // x64 (AMD or Intel)
  arm(Architecture.x32), // ARM
  arm64(Architecture.x64), // ARM64
  ia64(Architecture.x64), // Intel Itanium-based
  intel(Architecture.x32), // x86
  unknown(Architecture.unknown); // Unknown architecture.

  const ProcessorArchitecture(this.architecture);

  final Architecture architecture;
}
