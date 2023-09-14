import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class AdaptiveWindowSizedBox extends StatefulWidget {
  const AdaptiveWindowSizedBox({
    super.key,
    this.wScale,
    this.hScale,
    this.child,
  });

  final double? wScale;
  final double? hScale;
  final Widget? child;

  @override
  State<AdaptiveWindowSizedBox> createState() => _AdaptiveWindowStateSizedBox();
}

class _AdaptiveWindowStateSizedBox extends State<AdaptiveWindowSizedBox>
    with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowResize() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.single);
    return SizedBox(
      width:
          widget.wScale == null ? null : widget.wScale! * mediaData.size.width,
      height:
          widget.hScale == null ? null : widget.hScale! * mediaData.size.height,
      child: widget.child,
    );
  }
}
