import 'package:flutter/material.dart';
import '../../../constants.dart';

class NoNotificationScreen extends StatelessWidget {
  const NoNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('No Notifications'),
        backgroundColor: logoRed,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_off,
              size: 80,
              color: logoGreyDark,
            ),
            const SizedBox(height: 24),
            Text(
              'No Notifications Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: logoGreyDark,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ll receive notifications about your construction project updates, site visits, and important milestones here.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
