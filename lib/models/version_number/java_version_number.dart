import 'package:one_launcher/models/version_number/version_number.dart';

class JavaVersionNumber extends VersionNumber {
  JavaVersionNumber({
    required super.major,
    required super.minor,
    required super.revision,
    super.patched,
  });

  @override
  int get minor => super.minor!;

  @override
  int get revision => super.revision!;

  factory JavaVersionNumber.fromString(String value) {
    final split = value.split('.');
    final major = split[0];
    final minor = split.elementAtOrNull(1);
    final revision = split.elementAtOrNull(2);
    final patched = split.elementAtOrNull(3);
    if (minor == null || revision == null) {
      throw Exception("Java版本格式不正确");
    }
    return JavaVersionNumber(
      major: int.parse(major),
      minor: toInt(minor),
      revision: toInt(revision),
      patched: toInt(patched),
    );
  }
}
