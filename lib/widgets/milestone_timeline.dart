import 'package:flutter/material.dart';

class MilestoneTimeline extends StatelessWidget {
  final List<ProjectMilestone> milestones;
  final int currentMilestoneIndex;

  const MilestoneTimeline({
    Key? key,
    required this.milestones,
    required this.currentMilestoneIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Timeline',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: milestones.length,
              itemBuilder: (context, index) {
                final milestone = milestones[index];
                final isCompleted = index < currentMilestoneIndex;
                final isCurrent = index == currentMilestoneIndex;
                final isFuture = index > currentMilestoneIndex;

                return _MilestoneItem(
                  milestone: milestone,
                  isCompleted: isCompleted,
                  isCurrent: isCurrent,
                  isFuture: isFuture,
                  isLast: index == milestones.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  final ProjectMilestone milestone;
  final bool isCompleted;
  final bool isCurrent;
  final bool isFuture;
  final bool isLast;

  const _MilestoneItem({
    required this.milestone,
    required this.isCompleted,
    required this.isCurrent,
    required this.isFuture,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    Color indicatorColor;
    IconData indicatorIcon;
    
    if (isCompleted) {
      indicatorColor = const Color(0xFF10B981);
      indicatorIcon = Icons.check_circle;
    } else if (isCurrent) {
      indicatorColor = const Color(0xFF3B82F6);
      indicatorIcon = Icons.radio_button_checked;
    } else {
      indicatorColor = const Color(0xFF9CA3AF);
      indicatorIcon = Icons.radio_button_unchecked;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              indicatorIcon,
              color: indicatorColor,
              size: 32,
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 80,
              child: Text(
                milestone.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                  color: isFuture ? const Color(0xFF9CA3AF) : const Color(0xFF1F2937),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (!isLast)
          Container(
            width: 40,
            height: 2,
            margin: const EdgeInsets.only(bottom: 40),
            color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
          ),
      ],
    );
  }
}

class ProjectMilestone {
  final String name;
  final String? description;
  final DateTime? targetDate;

  const ProjectMilestone({
    required this.name,
    this.description,
    this.targetDate,
  });
}
