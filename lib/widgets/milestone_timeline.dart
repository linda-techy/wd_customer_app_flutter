import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants.dart';

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Timeline',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: milestones.length,
            itemBuilder: (context, index) {
              final milestone = milestones[index];
              final isCompleted = index < currentMilestoneIndex;
              final isCurrent = index == currentMilestoneIndex;
              final isLast = index == milestones.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Line & Dot Column
                    SizedBox(
                      width: 40,
                      child: Column(
                        children: [
                          // The Dot
                          _buildDot(isCompleted, isCurrent),
                          // The Line
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCompleted ? successColor : blackColor10,
                                  gradient: isCurrent
                                      ? LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [successColor, blackColor10],
                                        )
                                      : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content Column
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              milestone.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isCurrent ? FontWeight.bold : FontWeight.w600,
                                color: isFuture(index) ? blackColor40 : blackColor,
                              ),
                            ),
                            if (milestone.targetDate != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                "Target: ${_formatDate(milestone.targetDate!)}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isCurrent ? primaryColor : blackColor60,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (milestone.description != null && isCurrent) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: blackColor10),
                                ),
                                child: Text(
                                  milestone.description!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: blackColor80,
                                    height: 1.4,
                                  ),
                                ),
                              ).animate().fadeIn().slideX(begin: 0.1),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool isFuture(int index) => index > currentMilestoneIndex;

  Widget _buildDot(bool isCompleted, bool isCurrent) {
    if (isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: successColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
    } else if (isCurrent) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: primaryColor, width: 6),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .boxShadow(
            begin: BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 0, spreadRadius: 0),
            end: BoxShadow(color: primaryColor.withOpacity(0.0), blurRadius: 12, spreadRadius: 8),
            duration: 1500.ms,
          );
    } else {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: blackColor20, width: 2),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
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
