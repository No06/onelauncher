import 'package:one_launcher/models/version.dart';

class JavaVersion extends Version {
  JavaVersion({
    required super.major,
    required super.minor,
    required super.revision,
    super.patched,
  });

  @override
  int get minor => super.minor!;

  @override
  int get revision => super.revision!;

  factory JavaVersion.fromString(String value) {
    final split = value.split('.');
    final major = split[0];
    final minor = split.elementAtOrNull(1);
    final revision = split.elementAtOrNull(2);
    final patched = split.elementAtOrNull(3);
    if (minor == null || revision == null) {
      throw Exception("Java版本格式不正确");
    }
    return JavaVersion(
      major: int.parse(major),
      minor: int.tryParse(minor),
      revision: int.tryParse(revision),
      patched: int.tryParse(patched ?? ''),
    );
  }
}
