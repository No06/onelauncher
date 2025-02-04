import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:one_launcher/app.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/main.dart';
import 'package:one_launcher/models/game/client/game_type.dart';
import 'package:one_launcher/models/game/game.dart';
import 'package:one_launcher/models/game/game_path.dart';
import 'package:one_launcher/models/json_map.dart';
import 'package:one_launcher/pages/common/base_page.dart';
import 'package:one_launcher/pages/game_library_page/game_startup_dialog.dart';
import 'package:one_launcher/provider/account_provider.dart';
import 'package:one_launcher/provider/game_path_provider.dart';
import 'package:one_launcher/utils/extension/list_extension.dart';
import 'package:one_launcher/utils/extension/print_extension.dart';
import 'package:one_launcher/utils/file/file_picker.dart';
import 'package:one_launcher/utils/form_validator.dart';
import 'package:one_launcher/widgets/dialog.dart';
import 'package:one_launcher/widgets/dyn_mouse_scroll.dart';
import 'package:one_launcher/widgets/snackbar.dart';
import 'package:open_file/open_file.dart';

part 'configuration_page.dart';
part 'filter_rule_provider.dart';
part 'game_library_page.g.dart';
part 'home_page.dart';

class GameLibraryPage extends RoutePage {
  const GameLibraryPage({super.key, super.pageName = "开始游戏"});

  final tabs = const {
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
                tabAlignment: TabAlignment.start,
                dividerHeight: 0,
                isScrollable: true,
                tabs: tabs.keys.map((text) => Tab(text: text)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(children: tabs.values.toList()),
            ),
          ],
        ),
      ),
    );
  }
}
