import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'native.g.dart';

@JsonSerializable()
class Natives {
  const Natives(this.linux, this.osx, this.windows);

  factory Natives.fromJson(JsonMap json) => _$NativesFromJson(json);

  final Native? linux;
  final Native? osx;
  final Native? windows;
  JsonMap toJson() => _$NativesToJson(this);
}

@JsonEnum()
enum Native {
  osx("natives-osx"),
  linux("natives-linux"),
  windows("natives-windows");

  const Native(this.native);
  final String native;
}
