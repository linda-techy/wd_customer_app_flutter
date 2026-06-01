import 'package:flutter/material.dart';
import '../design_tokens/app_colors.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const DetailRow(this.label, this.value,
      {super.key, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.grey600, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.normal,
                  color: color,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
