import 'package:one_launcher/models/game/version/librarie/downloads.dart';
import 'package:one_launcher/models/game/version/librarie/librarie.dart';
import 'package:one_launcher/models/game/version/rule.dart';
import 'package:json_annotation/json_annotation.dart';

part 'common_librarie.g.dart';

@JsonSerializable()
class CommonLibrarie extends Librarie {
  CommonLibrarie({
    required super.name,
    required this.downloads,
    this.rules,
  });

  final Downloads downloads;
  final List<Rule>? rules;

  factory CommonLibrarie.fromJson(Map<String, dynamic> json) =>
      _$CommonLibrarieFromJson(json);
}
