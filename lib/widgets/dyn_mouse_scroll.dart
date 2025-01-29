import 'package:flutter/material.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

typedef DynMouseScrollBuilder = void Function(
  BuildContext context,
  ScrollController controller,
  ScrollPhysics physics,
);

class MyDynMouseScroll extends StatelessWidget {
  const MyDynMouseScroll({
    required this.builder,
    super.key,
    this.mobilePhysics = const BouncingScrollPhysics(),
    this.durationMS = 220,
    this.scrollSpeed = 2,
    this.animationCurve = Curves.fastEaseInToSlowEaseOut,
  });

  final ScrollPhysics mobilePhysics;
  final int durationMS;
  final double scrollSpeed;
  final Curve animationCurve;
  final DynMouseScrollBuilder builder;

  @override
  Widget build(BuildContext context) {
    return DynMouseScroll(
      mobilePhysics: mobilePhysics,
      animationCurve: animationCurve,
      durationMS: 220,
      scrollSpeed: scrollSpeed,
      builder: builder,
    );
  }
}
