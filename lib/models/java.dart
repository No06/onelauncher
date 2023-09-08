import 'package:beacon/utils/java_util.dart';
import 'package:json_annotation/json_annotation.dart';

part 'java.g.dart';

@JsonSerializable()
class Java {
  Java(this.path, {String? versionNumber, this.args = ""})
      : versionNumber = versionNumber ?? JavaUtil.getVersionByRun(path);

  final String path;
  final String versionNumber;
  final String args;

  String get version {
    final regex1 = RegExp(r"(\d+)");
    final regex2 = RegExp(r"\.(\d+)");
    final match1 = regex1.firstMatch(versionNumber);
    final match2 = regex2.firstMatch(versionNumber);
    if (match1 != null) {
      if (match1.group(1) == "1" && match2 != null) {
        return "${match2.group(1)}";
      } else {
        return "${match1.group(1)}";
      }
    } else {
      return "unknown";
    }
  }

  factory Java.fromJson(Map<String, dynamic> json) => _$JavaFromJson(json);

  Map<String, dynamic> toJson() => _$JavaToJson(this);

  @override
  int get hashCode {
    return path.hashCode ^ versionNumber.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Java) return false;
    return path == other.path && versionNumber == other.versionNumber;
  }
}
