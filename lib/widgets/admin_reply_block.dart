import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Displays an admin reply to a customer's feedback response.
///
/// When [adminResponse] is null the widget renders nothing (SizedBox.shrink).
/// When non-null it shows a clearly-labelled block with the reply text and the
/// date the reply was given.
///
/// This widget is purely presentational — it takes values, not a service call.
class AdminReplyBlock extends StatelessWidget {
  const AdminReplyBlock({
    super.key,
    required this.adminResponse,
    required this.adminRespondedAt,
  });

  final String? adminResponse;
  final DateTime? adminRespondedAt;

  static final DateFormat _dateFormat = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    if (adminResponse == null || adminResponse!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // light green tint — "positive" reply
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent_rounded,
                  size: 18, color: Color(0xFF16A34A)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Response from Walldot Builders',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
              if (adminRespondedAt != null)
                Text(
                  _dateFormat.format(adminRespondedAt!),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4B7A56),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            adminResponse!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
