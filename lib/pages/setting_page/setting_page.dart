import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/provider/game_setting_provider.dart';
import 'package:one_launcher/utils/extension/color_extension.dart';
import 'package:one_launcher/utils/java_util.dart';
import 'package:one_launcher/utils/platform/sys_info/sys_info.dart';
import 'package:one_launcher/widgets/dialog.dart';
import 'package:one_launcher/widgets/dyn_mouse_scroll.dart';
import 'package:one_launcher/pages/common/base_page.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:one_launcher/widgets/textfield.dart';
import 'package:one_launcher/widgets/widget_group.dart';

part 'game_setting_page.dart';

class SettingPage extends RoutePage {
  const SettingPage({super.key, super.pageName = "设置"});

  final tabs = const {
    "全局游戏设置": _GameSettingPage(),
    "启动器": _LauncherSettingPage(),
  };

  @override
  Widget body(BuildContext context) {
    return Expanded(
      child: DefaultTabController(
        length: tabs.length,
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
              child: TabBarView(
                children: tabs.values.toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract class _SettingBasePage extends StatelessWidget {
  const _SettingBasePage();

  Widget body(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return MyDynMouseScroll(
      builder: (context, controller, physics) => ListView(
        controller: controller,
        physics: physics,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [body(context)],
      ),
    );
  }
}

class _LauncherSettingPage extends _SettingBasePage {
  const _LauncherSettingPage();

  @override
  Widget body(BuildContext context) {
    return const SizedBox();
  }
}
