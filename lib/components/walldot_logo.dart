import 'package:flutter/material.dart';
import '../constants.dart';

class WalldotLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;
  final double textSize;

  const WalldotLogo({
    super.key,
    this.size = 120,
    this.showText = true,
    this.textColor,
    this.textSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Image - Always use the actual Walldot logo
        SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            'assets/logo/walldot_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            "Walldot Builders",
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.bold,
              color: textColor ?? logoRed,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}
