import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:one_launcher/models/config/theme_config.dart';
import 'package:one_launcher/widgets/dyn_mouse_scroll.dart';
import 'package:one_launcher/pages/base_page.dart';

class AppearancePage extends RoutePage {
  const AppearancePage({super.key, super.pageName = "外观"});

  final radioValues = const {
    ThemeMode.system: "跟随系统",
    ThemeMode.light: "浅色",
    ThemeMode.dark: "深色",
  };

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
                Consumer(builder: (context, ref, child) {
                  final themeMode = ref.watch(appThemeProvider).mode;
                  return Column(
                    children: List.generate(radioValues.length, (i) {
                      final radioValue = radioValues.entries.elementAt(i);
                      return _Radio(
                        text: radioValue.value,
                        themeMode: radioValue.key,
                        groupValue: themeMode,
                        onChanged:
                            ref.read(appThemeProvider.notifier).updateMode,
                      );
                    }),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({
    required this.text,
    required this.themeMode,
    required this.groupValue,
    required this.onChanged,
  });

  final String text;
  final ThemeMode themeMode;
  final ThemeMode groupValue;
  final void Function(ThemeMode?)? onChanged;

  @override
  Widget build(BuildContext context) {
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
}
