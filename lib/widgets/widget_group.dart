import 'package:one_launcher/consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_launcher/models/theme_config.dart';

class WidgetGroup extends StatelessWidget {
  const WidgetGroup({
    super.key,
    required this.divider,
    required this.children,
    this.width,
    this.height,
    this.backgroundColor,
    this.alignment,
    this.padding,
    this.margin,
    this.decoration,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.verticalDirection = VerticalDirection.down,
    this.textDirection,
    this.textBaseline,
  });

  final Widget divider;
  final List<Widget> children;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    for (int i = 1; i < children.length; i += 2) {
      children.insert(i, divider);
    }
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(
          bodyColor: colors.onSecondaryContainer,
        ),
      ),
      child: Material(
        color: backgroundColor ?? colors.secondaryContainer,
        borderRadius: kBorderRadius,
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: width,
          height: height,
          alignment: alignment,
          margin: margin,
          padding: padding,
          child: Column(
            mainAxisAlignment: mainAxisAlignment,
            mainAxisSize: mainAxisSize,
            crossAxisAlignment: crossAxisAlignment,
            textDirection: textDirection,
            verticalDirection: verticalDirection,
            textBaseline: textBaseline,
            children: children,
          ),
        ),
      ),
    );
  }
}

class TitleWidgetGroup extends StatelessWidget {
  const TitleWidgetGroup(
    this.title, {
    super.key,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: WidgetGroup(divider: _defaultDivider(), children: children),
        ),
      ],
    );
  }
}

class WidgetGroupBlock extends StatelessWidget {
  const WidgetGroupBlock({
    super.key,
    required this.title,
    required this.divider,
    required this.children,
    this.width,
    this.height,
    this.alignment,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.clipBehavior,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.verticalDirection = VerticalDirection.down,
    this.textDirection,
    this.textBaseline,
  });

  final Widget title;
  final Widget divider;
  final List<Widget> children;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final Clip? clipBehavior;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;

  Widget surface(Widget widget, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: borderRadius ?? kBorderRadius,
        color: color ?? colorWithValue(colors.secondaryContainer, .1),
        elevation: 2,
        child: widget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final List<Widget> children = () {
      var children = this.children;
      children = children.map((e) => surface(e, colors)).toList();
      return [title] + children;
    }();

    return Container(
      width: width,
      height: height,
      alignment: alignment,
      margin: margin,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? kBorderRadius,
        color: colors.secondaryContainer,
      ),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: children,
      ),
    );
  }
}

class ExpansionListTile extends StatelessWidget {
  const ExpansionListTile({
    super.key,
    required this.tile,
    required this.expandTile,
    required this.isExpaned,
  });

  final Widget tile;
  final Widget expandTile;
  final bool isExpaned;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      global: false,
      init: _AnimationController(isExpaned ? 1 : 0),
      builder: (c) {
        if (isExpaned) {
          c.animController.forward();
        } else {
          c.animController.reverse();
        }
        return Column(
          children: [
            tile,
            SizeTransition(
              axisAlignment: 1.0,
              sizeFactor: c.animation,
              child: expandTile,
            ),
          ],
        );
      },
    );
  }
}

class _AnimationController extends GetxController
    with GetSingleTickerProviderStateMixin {
  _AnimationController([this.value]);

  final double? value;
  late Animation<double> animation;
  late AnimationController animController;

  @override
  void onInit() {
    super.onInit();
    animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      value: value,
      vsync: this,
    );
    animation = Tween<double>(begin: 0.0, end: 1.0) // 添加tween
        .animate(CurvedAnimation(
      parent: animController,
      curve: Curves.fastOutSlowIn,
    ));
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }
}

Widget _defaultDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Divider(
      height: 1,
      color: Get.theme.colorScheme.onPrimaryContainer.withOpacity(.2),
    ),
  );
}
