import 'package:json_annotation/json_annotation.dart';

part 'os.g.dart';

@JsonSerializable()
class Os {
  const Os({required this.name});

  final OsName name;

  factory Os.fromJson(Map<String, dynamic> json) => _$OsFromJson(json);
}

@JsonEnum()
enum OsName {
  windows("windows"),
  linux("linux"),
  osx("osx"),
  unknown("unknown");

  const OsName(this.name);
  final String name;

  factory OsName.fromName(String name) {
    if (name == "macos") return osx;
    return $enumDecode(_$OsNameEnumMap, name, unknownValue: unknown);
  }
}
