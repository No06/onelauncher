import 'package:flutter/material.dart';

class MyWindowCaptionButtonColors {
  const MyWindowCaptionButtonColors({
    required this.normal,
    required this.mouseOver,
    required this.mouseDown,
    required this.iconNormal,
    required this.iconMouseOver,
    required this.iconMouseDown,
  });

  /// 浅色
  const MyWindowCaptionButtonColors.light({
    this.normal = Colors.transparent,
    this.mouseOver = const Color.fromARGB(20, 0, 0, 0),
    this.mouseDown = const Color.fromARGB(40, 0, 0, 0),
    this.iconNormal = const Color(0xe4000000),
    this.iconMouseOver = const Color(0xe4000000),
    this.iconMouseDown = const Color(0x9b000000),
  });

  /// 深色
  const MyWindowCaptionButtonColors.dark({
    this.normal = Colors.transparent,
    this.mouseOver = const Color.fromARGB(25, 255, 255, 255),
    this.mouseDown = const Color.fromARGB(35, 255, 255, 255),
    this.iconNormal = Colors.white,
    this.iconMouseOver = const Color(0xc8ffffff),
    this.iconMouseDown = const Color.fromRGBO(255, 255, 255, 0.365),
  });

  /// 关闭按钮浅色
  const MyWindowCaptionButtonColors.closeLight({
    this.normal = Colors.transparent,
    this.mouseOver = const Color(0xFFE81123),
    this.mouseDown = const Color.fromRGBO(154, 28, 41, 1),
    this.iconNormal = const Color(0xe4000000),
    this.iconMouseOver = Colors.white,
    this.iconMouseDown = Colors.white,
  });

  /// 关闭按钮深色
  const MyWindowCaptionButtonColors.closeDark({
    this.normal = Colors.transparent,
    this.mouseOver = const Color(0xFFE81123),
    this.mouseDown = const Color.fromRGBO(154, 28, 41, 1),
    this.iconNormal = Colors.white,
    this.iconMouseOver = Colors.white,
    this.iconMouseDown = Colors.white,
  });

  factory MyWindowCaptionButtonColors.adaptive(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const MyWindowCaptionButtonColors.light()
        : const MyWindowCaptionButtonColors.dark();
  }

  final Color normal;
  final Color mouseOver;
  final Color mouseDown;
  final Color iconNormal;
  final Color iconMouseOver;
  final Color iconMouseDown;
}
