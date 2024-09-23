class Version {
  const Version({
    required this.major,
    this.minor,
    this.revision,
    this.patched,
  });

  final int major;
  final int? minor;
  final int? revision;
  final int? patched;

  // 定义一个比较器，用于比较两个VersionNumber对象的大小
  int compareTo(Version other) {
    // 先比较主版本号
    if (major > other.major) return 1;
    if (major < other.major) return -1;
    // 主版本号相同，再比较次版本号
    if (minor != null && other.minor != null) {
      if (minor! > other.minor!) return 1;
      if (minor! < other.minor!) return -1;
    }
    // 次版本号相同或者有一个为空，再比较修订号
    if (revision != null && other.revision != null) {
      if (revision! > other.revision!) return 1;
      if (revision! < other.revision!) return -1;
    }
    // 修订号相同或者有一个为空，再比较补丁号
    if (patched != null && other.patched != null) {
      if (patched! > other.patched!) return 1;
      if (patched! < other.patched!) return -1;
    }
    // 所有版本号都相同或者有一个为空，返回0
    return 0;
  }

  /// 传入 1.x.x 格式的字符串
  factory Version.fromString(String value) {
    final split = value.split('.');
    final major = split[0];
    final minor = split.elementAtOrNull(1);
    final revision = split.elementAtOrNull(2);
    final patched = split.elementAtOrNull(3);
    return Version(
      major: int.parse(major),
      minor: int.tryParse(minor ?? ''),
      revision: int.tryParse(revision ?? ''),
      patched: int.tryParse(patched ?? ''),
    );
  }
}
