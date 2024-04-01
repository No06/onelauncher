import 'dart:io';

import 'package:one_launcher/models/game/data/library/downloads.dart';
import 'package:one_launcher/models/game/data/library/library.dart';
import 'package:one_launcher/models/game/data/os.dart';
import 'package:one_launcher/models/game/data/os_rule.dart';
import 'package:one_launcher/models/game/data/rule.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/json_map.dart';

part 'common_library.g.dart';

@JsonSerializable()
class CommonLibrary extends Library {
  CommonLibrary({
    required super.name,
    required this.downloads,
    this.rules,
  });

  late final Downloads downloads;
  late final List<Rule>? rules;

  /// 根据规则判断是否需要
  bool get isAllowed {
    if (rules != null) {
      final osRules = <OsName>{};
      for (var rule in rules!) {
        final action = rule.action;
        switch (action) {
          case RuleAction.allow:
            if (rule is OsRule) {
              osRules.add(rule.os.name);
            } else {
              osRules.addAll(OsName.values);
            }
          case RuleAction.disallow:
            if (rule is OsRule) {
              osRules.remove(rule.os.name);
            } else {
              osRules.clear();
            }
        }
      }
      final operatingSystem = Platform.operatingSystem;
      return osRules.isEmpty ||
          osRules.contains(OsName.fromName(operatingSystem));
    }
    return true;
  }

  factory CommonLibrary.fromJson(JsonMap json) => _$CommonLibraryFromJson(json);
}
