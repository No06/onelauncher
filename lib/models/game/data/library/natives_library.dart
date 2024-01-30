import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/data/library/common_library.dart';
import 'package:one_launcher/models/game/data/library/downloads.dart';
import 'package:one_launcher/models/game/data/library/extract.dart';
import 'package:one_launcher/models/game/data/os.dart';
import 'package:one_launcher/models/game/data/rule.dart';

part 'natives_library.g.dart';

@JsonSerializable()
class NativesLibrary extends CommonLibrary {
  NativesLibrary({
    required super.name,
    required super.downloads,
    super.rules,
    required this.natives,
    this.extractRule,
  });

  static final currentOsName = OsName.fromName(Platform.operatingSystem);

  final Map<OsName, String> natives;
  @JsonKey(name: "extract")
  final ExtractRule? extractRule;

  String? get osNameString => natives[currentOsName];

  factory NativesLibrary.fromJson(Map<String, dynamic> json) =>
      _$NativesLibraryFromJson(json);
}
