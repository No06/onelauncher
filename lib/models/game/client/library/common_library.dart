import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:one_launcher/models/game/client/library/downloads.dart';
import 'package:one_launcher/models/game/client/library/library.dart';
import 'package:one_launcher/models/game/client/os.dart';
import 'package:one_launcher/models/game/client/os_rule.dart';
import 'package:one_launcher/models/game/client/rule.dart';
import 'package:one_launcher/models/json_map.dart';

part 'common_library.g.dart';

@JsonSerializable()
class CommonLibrary extends Library {
  CommonLibrary({
    required super.name,
    required this.downloads,
    this.rules,
  });

  factory CommonLibrary.fromJson(JsonMap json) => _$CommonLibraryFromJson(json);

  final Downloads downloads;
  final List<Rule>? rules;

  /// 根据规则判断是否需要
  bool get isAllowed {
    if (rules != null) {
      final osRules = <OsName>{};
      for (final rule in rules!) {
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

  @override
  JsonMap toJson() => _$CommonLibraryToJson(this);
}
