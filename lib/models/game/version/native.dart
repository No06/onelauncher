import 'package:json_annotation/json_annotation.dart';

part 'native.g.dart';

@JsonSerializable()
class Natives {
  Natives(this.linux, this.osx, this.windows);

  final Native? linux;
  final Native? osx;
  final Native? windows;

  factory Natives.fromJson(Map<String, dynamic> json) =>
      _$NativesFromJson(json);
}

@JsonEnum()
enum Native {
  osx("natives-osx"),
  linux("natives-linux"),
  windows("natives-windows");

  const Native(this.native);
  final String native;
}
