import 'package:flutter/material.dart';

class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeSlidePageRoute({
    required this.page,
    super.settings,
    Duration duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(0.05, 0.0); // Slight slide from right
            var end = Offset.zero;
            var curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}
