import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../models/timeline_item.dart';

class TimelineTaskCard extends StatelessWidget {
  final TimelineItem item;
  const TimelineTaskCard({super.key, required this.item});

  Color _statusColor(String label) => switch (label) {
    'ON_SCHEDULE' => Colors.green,
    'ON_TRACK' => Colors.blue,
    'AT_RISK' => Colors.orange,
    'DELAYED' => Colors.red,
    _ => Colors.grey,
  };

  IconData _statusIcon(String label) => switch (label) {
    'ON_SCHEDULE' => Icons.check_circle,
    'ON_TRACK' => Icons.timelapse,
    'AT_RISK' => Icons.warning,
    'DELAYED' => Icons.error,
    _ => Icons.help,
  };

  String _label(String l) => switch (l) {
    'ON_SCHEDULE' => 'On schedule',
    'ON_TRACK' => 'On track',
    'AT_RISK' => 'At risk',
    'DELAYED' => 'Delayed',
    _ => l,
  };

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM');
    final color = _statusColor(item.statusLabel);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (item.milestoneName != null)
            Text(item.milestoneName!,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.progressPercent / 100.0,
              backgroundColor: Colors.grey.shade200,
              color: color,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Icon(_statusIcon(item.statusLabel), size: 14, color: color),
            const SizedBox(width: 4),
            Text(_label(item.statusLabel),
                style: TextStyle(color: color, fontSize: 12)),
            const Spacer(),
            if (item.plannedStart != null && item.plannedEnd != null)
              Text(
                  '${fmt.format(item.plannedStart!)} – ${fmt.format(item.plannedEnd!)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ]),
      ),
    );
  }
}
