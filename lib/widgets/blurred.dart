import 'dart:ui';

import 'package:flutter/material.dart';

/// Convenience widget to create blurred images.
/// `BlurredImage.asset` behaves like `Image.asset`, and
/// `BlurredImage.network` behaves like `Image.network`.
class BlurredImage extends StatelessWidget {
  BlurredImage.asset(
    String imagePath, {
    super.key,
    this.blurValue = 5,
  }) : imageWidget = Image.asset(
          imagePath,
          width: double.infinity,
          fit: BoxFit.fitWidth,
        );

  BlurredImage.network(
    String url, {
    super.key,
    this.blurValue = 5,
  }) : imageWidget = Image.network(
          url,
          width: double.infinity,
          fit: BoxFit.fitWidth,
        );

  final double blurValue;
  final Widget imageWidget;

  @override
  Widget build(BuildContext context) {
    return Blurred(
      imageWidget,
      blurValue: blurValue,
    );
  }
}

/// Wrapper widget that blurs the wudget passed to it.
/// Any widget passed to the `child` argument will not be blurred.
/// The higher the `blurValue`, the stronger the blur effect.
class Blurred extends StatelessWidget {
  const Blurred(
    this.widget, {
    super.key,
    this.child,
    this.blurValue = 5,
    this.alignment = Alignment.center,
  });

  final Widget widget;
  final Widget? child;
  final double blurValue;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        alignment: alignment,
        children: [
          widget,
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
              child: const SizedBox(),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// Convenience wrapper to create an acrylic effect Container.
/// Any widget passed to the `child` argument will not be blurred.
/// The higher the `blurValue`, the stronger the blur effect.
/// The `color` and `alpha` can be adjusted to suit your needs.
class Acrylic extends StatelessWidget {
  const Acrylic({
    super.key,
    this.child,
    this.blurValue = 20,
    this.color = Colors.white,
    this.opacity = .2,
    this.alignment = Alignment.center,
  });

  final Widget? child;
  final double blurValue;
  final Color color;
  final double opacity;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Blurred(
      Container(color: color.withOpacity(opacity)),
      blurValue: blurValue,
      alignment: alignment,
      child: child,
    );
  }
}
