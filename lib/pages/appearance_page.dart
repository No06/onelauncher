import 'package:beacon/models/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/route_page.dart';

class AppearancePage extends RoutePage {
  const AppearancePage({super.key});

  @override
  String routeName() => "外观";

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        title(),
        body(),
      ],
    );
  }

  Widget radio(
    String text,
    ThemeMode themeMode,
    ThemeMode groupValue,
    void Function(ThemeMode?)? onChanged,
  ) {
    return Row(
      children: [
        Radio(
          value: themeMode,
          groupValue: groupValue,
          onChanged: onChanged,
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
        ObxValue(
          (p0) => Column(
            children: radioValues.entries
                .map(
                  (e) => radio(
                    e.value,
                    e.key,
                    p0.value,
                    (value) {
                      Get.changeThemeMode(e.key);
                      p0.value = value!;
                      AppConfig.instance.theme.mode = value;
                    },
                  ),
                )
                .toList(),
          ),
          AppConfig.instance.theme.mode.obs,
        )
      ],
    );
  }
}
