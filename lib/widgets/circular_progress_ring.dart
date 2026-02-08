import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularProgressRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? color;
  final String? overrideText;
  final String? overrideSubtext;
  final bool showPercentage;
  final Color? textColor;
  final Color? subTextColor;

  const CircularProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    this.color,
    this.showPercentage = true,
    this.overrideText,
    this.overrideSubtext,
    this.textColor,
    this.subTextColor,
  });

  @override
  State<CircularProgressRing> createState() => _CircularProgressRingState();
}

class _CircularProgressRingState extends State<CircularProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(CircularProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.7) return const Color(0xFF10B981); // Green
    if (progress >= 0.4) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progressColor = widget.color ?? _getProgressColor(_animation.value);
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircleProgressPainter(
                  progress: 1.0,
                  strokeWidth: widget.strokeWidth,
                  color: Colors.grey.shade200.withOpacity(0.3),
                ),
              ),
              // Progress circle
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircleProgressPainter(
                  progress: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  color: progressColor,
                ),
              ),
              // Percentage text
              if (widget.showPercentage)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.overrideText ?? '${(_animation.value * 100).toInt()}%',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: widget.overrideText != null ? widget.size * 0.15 : widget.size * 0.25,
                        fontWeight: FontWeight.bold,
                        color: widget.textColor ?? const Color(0xFF1F2937),
                      ),
                    ),
                    if (widget.overrideSubtext != null || widget.overrideText == null)
                      Text(
                        widget.overrideSubtext ?? 'Complete',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: widget.size * 0.1,
                          color: widget.subTextColor ?? const Color(0xFF6B7280),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _CircleProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
