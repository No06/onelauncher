import 'dart:io';

import 'package:one_launcher/models/game/version/librarie/downloads.dart';
import 'package:one_launcher/models/game/version/librarie/librarie.dart';
import 'package:one_launcher/models/game/version/os.dart';
import 'package:one_launcher/models/game/version/os_rule.dart';
import 'package:one_launcher/models/game/version/rule.dart';
import 'package:json_annotation/json_annotation.dart';

part 'common_librarie.g.dart';

@JsonSerializable()
class CommonLibrary extends Library {
  CommonLibrary({
    required super.name,
    required this.downloads,
    this.rules,
  });

  final Downloads downloads;
  final List<Rule>? rules;

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

  factory CommonLibrary.fromJson(Map<String, dynamic> json) =>
      _$CommonLibrarieFromJson(json);
}
