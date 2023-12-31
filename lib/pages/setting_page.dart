import 'package:one_launcher/consts.dart';
import 'package:one_launcher/models/config/app_config.dart';
import 'package:one_launcher/pages/game_setting_page.dart';
import 'package:one_launcher/widgets/route_page.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class SettingPage extends RoutePage {
  SettingPage({super.key, required super.pageName});

  final tabs = {
    "全局游戏设置": GameSettingPage(config: appConfig.gameSetting),
    "启动器": const _LauncherSettingPage(),
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
    return DynMouseScroll(
      animationCurve: kMouseScrollAnimationCurve,
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
