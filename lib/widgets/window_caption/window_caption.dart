import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class MyWindowCaption extends StatelessWidget {
  const MyWindowCaption({
    super.key,
    this.brightness,
    this.title,
    this.backgroundColor,
    this.icons,
  });

  final Brightness? brightness;
  final Widget? title;
  final Color? backgroundColor;
  final List<Widget>? icons;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ??
            (brightness == Brightness.dark
                ? const Color(0xff1C1C1C)
                : Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: SizedBox(
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: brightness == Brightness.light
                          ? Colors.black.withOpacity(0.8956)
                          : Colors.white,
                      fontSize: 14,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: title,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ...?icons,
        ],
      ),
    );
  }
}
