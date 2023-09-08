import 'package:json_annotation/json_annotation.dart';

part 'os.g.dart';

@JsonSerializable()
class Os {
  Os({required this.name});

  final OsName name;

  factory Os.fromJson(Map<String, dynamic> json) => _$OsFromJson(json);
}

@JsonEnum()
enum OsName {
  windows("windows"),
  linux("linux"),
  osx("osx");

  const OsName(this.name);
  final String name;
}
