import 'package:one_launcher/models/version.dart';

class GameVersion extends Version {
  GameVersion({
    required super.major,
    required super.minor,
    super.revision,
    super.patched,
  });

  @override
  int get minor => super.minor!;

  factory GameVersion.fromString(String value) {
    final split = value.split('.');
    final major = split[0];
    final minor = split.elementAtOrNull(1);
    final revision = split.elementAtOrNull(2);
    final patched = split.elementAtOrNull(3);
    if (minor == null) {
      throw Exception("游戏版本格式不正确");
    }
    return GameVersion(
      major: int.parse(major),
      minor: int.tryParse(minor),
      revision: int.tryParse(revision ?? ''),
      patched: int.tryParse(patched ?? ''),
    );
  }
}
