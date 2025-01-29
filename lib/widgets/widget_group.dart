import 'package:flutter/material.dart';
import 'package:one_launcher/consts.dart';
import 'package:one_launcher/utils/extension/list_extension.dart';

class WidgetGroup extends StatelessWidget {
  const WidgetGroup({
    required this.divider,
    required this.children,
    super.key,
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
    final children = List<Widget>.from(this.children)..joinWith(divider);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(
          bodyColor: colors.onSecondaryContainer,
        ),
      ),
      child: Material(
        color: backgroundColor ?? colors.secondaryContainer,
        borderRadius: kDefaultBorderRadius,
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
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  Widget _defaultDivider(BuildContext context) => Divider(
        height: 1,
        color:
            Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(.08),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: WidgetGroup(
            divider: _defaultDivider(context),
            children: children,
          ),
        ),
      ],
    );
  }
}

class ExpansionListTile extends StatefulWidget {
  const ExpansionListTile({
    required this.title,
    required this.child,
    required this.isExpaned,
    super.key,
    this.keepVisible = false,
  });

  final Widget title;
  final Widget child;
  final bool isExpaned;
  final bool keepVisible;

  @override
  State<ExpansionListTile> createState() => _ExpansionListTileState();
}

class _ExpansionListTileState extends State<ExpansionListTile>
    with SingleTickerProviderStateMixin {
  late Widget? _child;
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _child = widget.isExpaned ? widget.child : null;
    controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      value: widget.isExpaned ? 1 : 0,
      vsync: this,
    );
    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void forward() {
    _child ??= widget.child;
    controller.forward();
  }

  void reverse() {
    controller.reverse().then((value) {
      // 将组件设置为 null 减少性能开销
      if (!widget.keepVisible) {
        setState(() => _child = null);
      }
    });
  }

  @override
  void didUpdateWidget(ExpansionListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpaned != oldWidget.isExpaned) {
      widget.isExpaned ? forward() : reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.title,
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return SizeTransition(
              axisAlignment: 1,
              sizeFactor: animation,
              child: child,
            );
          },
          child: _child,
        ),
      ],
    );
  }
}
