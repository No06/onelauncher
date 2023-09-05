import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key, this.assetName});
  final String? assetName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(assetName!),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "1.8",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                SizedBox(
                  height: 30,
                  width: 180,
                  child: GetBuilder<_TabController>(
                    init: _TabController(),
                    builder: (c) => TabBar(
                      controller: c.tabController,
                      dividerColor: Colors.transparent,
                      tabs: c.tabs.map((e) => Tab(text: e)).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GetBuilder(
              init: _TabController(),
              builder: (c) => TabBarView(
                controller: c.tabController,
                children: const [_HomePage(), _SetupPage()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final tabs = ["开始游戏", "配置"];
  late final TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "主页",
        style: Theme.of(context).textTheme.displayLarge,
      ),
    );
  }
}

class _SetupPage extends StatelessWidget {
  const _SetupPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "配置",
        style: Theme.of(context).textTheme.displayLarge,
      ),
    );
  }
}
