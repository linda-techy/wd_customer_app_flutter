import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants.dart';

class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double liftAmount;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.liftAmount = -4.0,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: widget.child.animate(
          target: _isPressed ? 2 : (_isHovered ? 1 : 0),
        )
        // Hover State (1)
        .moveY(end: widget.liftAmount, duration: kFastDuration, curve: kStandardCurve)
        .elevation(end: 8, duration: kFastDuration)
        // Press State (2)
        .scaleXY(end: 0.98, duration: kFastDuration, curve: kButtonScaleCurve),
      ),
    );
  }
}
