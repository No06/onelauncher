import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nil/nil.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/app_config.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/models/game_path_config.dart';
import 'package:one_launcher/models/read_write_value_notifier.dart';
import 'package:one_launcher/pages/game_startup_page.dart';
import 'package:one_launcher/widgets/build_widgets_with_divider.dart';
import 'package:one_launcher/utils/file_picker.dart';
import 'package:one_launcher/widgets/dialog.dart';
import 'package:one_launcher/widgets/route_page.dart';
import 'package:one_launcher/widgets/snackbar.dart';

part 'filter_rule.dart';
part 'home_page.dart';
part 'configuration_page.dart';

_FilterRule get _filterRule => _FilterRule.instance;

class GameLibraryPage extends RoutePage {
  GameLibraryPage({super.key, required super.pageName});

  late final tabs = {
    "主页": _HomePage(),
    "配置": _ConfigurationPage(),
  };

  @override
  Widget body(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 35,
              child: TabBar(
                isScrollable: true,
                tabs: tabs.keys.map((text) => Tab(text: text)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(children: tabs.values.toList()),
            )
          ],
        ),
      ),
    );
  }
}
