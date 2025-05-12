import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_launcher/pages/common/base_page.dart';
import 'package:one_launcher/pages/download_page/install_game_dialog.dart';
import 'package:intl/intl.dart';
part 'download_game_page.dart';

class DownloadPage extends RoutePage {
  const DownloadPage({super.key, super.pageName = "下载"});

  final tabs = const {
    "游戏下载": _GameDownloadPage(),
    // "Mod": _ModDownloadPage(),
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
