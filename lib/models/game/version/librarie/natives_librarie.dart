import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/version/librarie/common_librarie.dart';
import 'package:one_launcher/models/game/version/librarie/downloads.dart';
import 'package:one_launcher/models/game/version/librarie/extract.dart';
import 'package:one_launcher/models/game/version/os.dart';
import 'package:one_launcher/models/game/version/rule.dart';

part 'natives_librarie.g.dart';

@JsonSerializable()
class NativesLibrarie extends CommonLibrarie {
  NativesLibrarie({
    required super.name,
    required super.downloads,
    super.rules,
    required this.natives,
    this.extract,
  });

  final Map<OsName, String> natives;
  final Extract? extract;

  factory NativesLibrarie.fromJson(Map<String, dynamic> json) =>
      _$NativesLibrarieFromJson(json);
}
