import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, this.projectId});

  final int? projectId; // Support direct project ID for web refresh

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool isLoggedIn = false;
  int selectedPhase = 0;
  int? projectId;

  @override
  void initState() {
    super.initState();
    projectId = widget.projectId;
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    setState(() {
      isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Project Schedule"),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text("Please log in to access project schedule"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Schedule"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening calendar view...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing schedule...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Progress
            Container(
              padding: const EdgeInsets.all(defaultPadding * 1.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Overall Progress",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "75%",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              "Completed",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "3 months",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              "Remaining",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: defaultPadding),
                  LinearProgressIndicator(
                    value: 0.75,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    minHeight: 8,
                  ),
                ],
              ),
            ),

            const SizedBox(height: defaultPadding * 1.5),

            // Phase Selector
            Text(
              "Project Phases",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: defaultPadding),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPhaseButton(
                      "Foundation", 0, Icons.foundation, Colors.blue),
                  _buildPhaseButton(
                      "Structure", 1, Icons.construction, Colors.green),
                  _buildPhaseButton(
                      "Electrical", 2, Icons.electric_bolt, Colors.orange),
                  _buildPhaseButton(
                      "Plumbing", 3, Icons.plumbing, Colors.purple),
                  _buildPhaseButton("Finishing", 4, Icons.brush, Colors.red),
                ],
              ),
            ),

            const SizedBox(height: defaultPadding * 1.5),

            // Phase Details
            _buildPhaseDetails(),

            const SizedBox(height: defaultPadding * 1.5),

            // Timeline
            Text(
              "Timeline",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: defaultPadding),

            _buildTimelineItem(
                "Project Start",
                "January 15, 2024",
                "Project initiation and planning",
                Icons.play_arrow,
                Colors.green),
            _buildTimelineItem("Foundation Complete", "March 1, 2024",
                "Foundation work completed", Icons.check_circle, Colors.green),
            _buildTimelineItem("Structure Work", "May 15, 2024",
                "Structural work in progress", Icons.pending, Colors.orange),
            _buildTimelineItem("Electrical & Plumbing", "July 1, 2024",
                "MEP work scheduled", Icons.schedule, Colors.blue),
            _buildTimelineItem("Finishing Work", "August 15, 2024",
                "Interior and exterior finishing", Icons.schedule, Colors.blue),
            _buildTimelineItem("Project Completion", "October 1, 2024",
                "Final handover", Icons.flag, Colors.grey),

            const SizedBox(height: defaultPadding * 1.5),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Downloading schedule...')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text("Download"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: defaultPadding),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Opening detailed timeline...')),
                      );
                    },
                    icon: const Icon(Icons.timeline),
                    label: const Text("Timeline"),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: defaultPadding),
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseButton(
      String title, int index, IconData icon, Color color) {
    final isSelected = selectedPhase == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPhase = index;
        });
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: defaultPadding),
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseDetails() {
    final phases = [
      {
        'title': 'Foundation',
        'progress': 100,
        'status': 'Completed',
        'description':
            'Site preparation, excavation, and foundation work completed successfully.',
        'startDate': 'Jan 15, 2024',
        'endDate': 'Mar 1, 2024',
      },
      {
        'title': 'Structure',
        'progress': 60,
        'status': 'In Progress',
        'description':
            'Structural work including walls, columns, and beams in progress.',
        'startDate': 'Mar 1, 2024',
        'endDate': 'May 15, 2024',
      },
      {
        'title': 'Electrical',
        'progress': 0,
        'status': 'Pending',
        'description': 'Electrical wiring, fixtures, and systems installation.',
        'startDate': 'May 15, 2024',
        'endDate': 'Jul 1, 2024',
      },
      {
        'title': 'Plumbing',
        'progress': 0,
        'status': 'Pending',
        'description':
            'Plumbing systems, fixtures, and water supply installation.',
        'startDate': 'May 15, 2024',
        'endDate': 'Jul 1, 2024',
      },
      {
        'title': 'Finishing',
        'progress': 0,
        'status': 'Pending',
        'description':
            'Interior and exterior finishing, painting, and landscaping.',
        'startDate': 'Jul 1, 2024',
        'endDate': 'Oct 1, 2024',
      },
    ];

    final phase = phases[selectedPhase];

    return Container(
      padding: const EdgeInsets.all(defaultPadding * 1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                phase['title'] as String,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(phase['status'] as String),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  phase['status'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          Text(
            phase['description'] as String,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: defaultPadding),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Start Date",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    Text(
                      phase['startDate'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "End Date",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    Text(
                      phase['endDate'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          LinearProgressIndicator(
            value: (phase['progress'] as int) / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            "${phase['progress']}% Complete",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, String description,
      IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: defaultPadding),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'pending':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
