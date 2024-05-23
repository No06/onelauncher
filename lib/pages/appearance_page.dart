import 'package:one_launcher/models/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_launcher/widgets/dyn_mouse_scroll.dart';
import 'package:one_launcher/pages/base_page.dart';

class AppearancePage extends RoutePage {
  const AppearancePage({super.key, super.pageName = "外观"});

  final radioValues = const {
    ThemeMode.system: "跟随系统",
    ThemeMode.light: "浅色",
    ThemeMode.dark: "深色",
  };

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
          child: Text(text, style: const TextStyle(height: 1)),
        )
      ],
    );
  }

  @override
  Widget body(BuildContext context) {
    return Expanded(
      child: MyDynMouseScroll(
        builder: (context, controller, physics) => ListView(
          controller: controller,
          physics: physics,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "主题",
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                    height: 1.5,
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
            ),
          ],
        ),
      ),
    );
  }
}
