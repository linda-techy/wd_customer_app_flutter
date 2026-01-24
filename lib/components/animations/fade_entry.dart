import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants.dart';

class FadeEntry extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;

  const FadeEntry({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = kDefaultDuration,
    this.slideOffset = const Offset(0, 20),
  });

  @override
  Widget build(BuildContext context) {
    return child.animate(delay: delay)
      .fadeIn(duration: duration, curve: kStandardCurve)
      .move(
        begin: slideOffset,
        duration: duration,
        curve: kStandardCurve,
      );
  }
}
