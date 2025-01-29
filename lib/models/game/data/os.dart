import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'os.g.dart';

@JsonSerializable()
class Os {
  const Os({required this.name});

  factory Os.fromJson(JsonMap json) => _$OsFromJson(json);

  final OsName name;
  JsonMap toJson() => _$OsToJson(this);
}

@JsonEnum()
enum OsName {
  windows("windows"),
  linux("linux"),
  osx("osx"),
  unknown("unknown");

  const OsName(this.name);

  factory OsName.fromName(String name) {
    if (name == "macos") return osx;
    return $enumDecode(_$OsNameEnumMap, name, unknownValue: unknown);
  }

  final String name;
}
