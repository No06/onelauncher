import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_launcher/widgets/window_caption/button_color.dart';
import 'package:one_launcher/widgets/window_caption/icons.dart';

class MyWindowCaptionButton extends StatelessWidget {
  MyWindowCaptionButton({
    super.key,
    this.brightness = Brightness.light,
    this.icon,
    this.onPressed,
    this.backgroundColor = Colors.transparent,
    this.animated = false,
  })  : lightColors = null,
        darkColors = null,
        _type = null;

  MyWindowCaptionButton.close({
    super.key,
    this.brightness = Brightness.light,
    this.onPressed,
    this.lightColors = const MyWindowCaptionButtonColors.closeLight(),
    this.darkColors = const MyWindowCaptionButtonColors.closeDark(),
    this.animated = false,
  })  : backgroundColor = null,
        icon = null,
        _type = _ButtonType.close;

  MyWindowCaptionButton.unmaximize({
    super.key,
    this.brightness = Brightness.light,
    this.onPressed,
    this.lightColors = const MyWindowCaptionButtonColors.light(),
    this.darkColors = const MyWindowCaptionButtonColors.dark(),
    this.animated = false,
  })  : backgroundColor = null,
        icon = null,
        _type = _ButtonType.unmaximize;

  MyWindowCaptionButton.maximize({
    super.key,
    this.brightness = Brightness.light,
    this.onPressed,
    this.lightColors = const MyWindowCaptionButtonColors.light(),
    this.darkColors = const MyWindowCaptionButtonColors.dark(),
    this.animated = false,
  })  : backgroundColor = null,
        icon = null,
        _type = _ButtonType.maximize;

  MyWindowCaptionButton.minimize({
    super.key,
    this.brightness = Brightness.light,
    this.onPressed,
    this.lightColors = const MyWindowCaptionButtonColors.light(),
    this.darkColors = const MyWindowCaptionButtonColors.dark(),
    this.animated = false,
  })  : backgroundColor = null,
        icon = null,
        _type = _ButtonType.minimize;

  final Brightness brightness;
  final Widget? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final MyWindowCaptionButtonColors? lightColors;
  final MyWindowCaptionButtonColors? darkColors;
  final bool animated;
  final _ButtonType? _type;

  final isHover = RxBool(false);
  final isPressed = RxBool(false);

  MyWindowCaptionButtonColors get colors {
    if (brightness == Brightness.light) {
      return lightColors!;
    }
    return darkColors!;
  }

  Color get _backgroundColor {
    if (isPressed.value) {
      return colors.mouseDown;
    }
    if (isHover.value) {
      return colors.mouseOver;
    }
    return colors.normal;
  }

  Color get iconColor {
    if (isPressed.value) {
      return colors.iconMouseDown;
    }
    if (isHover.value) {
      return colors.iconMouseOver;
    }
    return colors.iconNormal;
  }

  Widget get _icon {
    switch (_type!) {
      case _ButtonType.close:
        return CloseIcon(color: iconColor);
      case _ButtonType.unmaximize:
        return RestoreIcon(color: iconColor);
      case _ButtonType.maximize:
        return MaximizeIcon(color: iconColor);
      case _ButtonType.minimize:
        return MinimizeIcon(color: iconColor);
    }
  }

  /// 颜色渐变动画时长
  static const animatedTime = 120;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (value) => isHover(false),
      onHover: (value) => isHover(true),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => isPressed(true),
        onTapCancel: () => isPressed(false),
        onTapUp: (_) => isPressed(false),
        onTap: onPressed,
        child: Obx(
          () => AnimatedContainer(
            duration: animated
                ? const Duration(milliseconds: animatedTime)
                : Duration.zero,
            curve: Curves.linear,
            color: _backgroundColor,
            constraints: const BoxConstraints(minWidth: 46, minHeight: 32),
            child: Center(child: _type == null ? icon : _icon),
          ),
        ),
      ),
    );
  }
}

enum _ButtonType {
  close,
  unmaximize,
  maximize,
  minimize,
}
