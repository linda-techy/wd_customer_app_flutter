import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants.dart';

class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double scaleAmount;

  const ScaleButton({
    super.key,
    required this.child,
    required this.onTap,
    this.duration = kFastDuration,
    this.scaleAmount = 0.95,
  });

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: widget.child.animate(target: _isPressed ? 1 : 0)
        .scaleXY(
          end: widget.scaleAmount,
          duration: widget.duration,
          curve: kButtonScaleCurve,
        ),
    );
  }
}
