import 'package:flutter/material.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

class MyDynMouseScroll extends StatelessWidget {
  const MyDynMouseScroll({
    super.key,
    this.mobilePhysics = const BouncingScrollPhysics(),
    this.durationMS = 220,
    this.scrollSpeed = 2,
    this.animationCurve = Curves.fastEaseInToSlowEaseOut,
    required this.builder,
  });

  final ScrollPhysics mobilePhysics;
  final int durationMS;
  final double scrollSpeed;
  final Curve animationCurve;
  final Function(BuildContext, ScrollController, ScrollPhysics) builder;

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
