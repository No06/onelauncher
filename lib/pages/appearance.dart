import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:beacon/controller/storage.dart';

import '/widgets/page.dart';

class AppearancePage extends RoutePage {
  const AppearancePage({super.key});

  @override
  String routeName() => "外观";

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [title(), body()],
    );
  }

  Widget radio(
    ThemeMode themeMode,
    String text,
    Rx<ThemeMode> groupValue,
    void Function(ThemeMode?)? onChanged,
  ) {
    return Row(
      children: [
        Obx(
          () => Radio(
            value: themeMode,
            groupValue: groupValue.value,
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(text),
        )
      ],
    );
  }

  Widget body() {
    const radioValues = {
      ThemeMode.system: "跟随系统",
      ThemeMode.light: "浅色",
      ThemeMode.dark: "深色",
    };
    final configController = Get.find<ConfigController>();
    final theme = configController.appTheme;
    final rxThemeMode = theme.mode.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "主题",
          style: TextStyle(
            fontSize: Theme.of(Get.context!).textTheme.titleLarge!.fontSize,
          ),
        ),
        const SizedBox(height: 5),
        Column(
          children: radioValues.entries
              .map(
                (e) => radio(
                  e.key,
                  e.value,
                  rxThemeMode,
                  (value) {
                    rxThemeMode(value);
                    theme.mode = rxThemeMode.value;
                    configController.updateConfig();
                    Get.changeThemeMode(e.key);
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
