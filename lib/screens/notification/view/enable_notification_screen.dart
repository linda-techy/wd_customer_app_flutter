import 'package:flutter/material.dart';
import '../../../constants.dart';

class EnableNotificationScreen extends StatelessWidget {
  const EnableNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enable Notifications'),
        backgroundColor: logoRed,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_active,
              size: 80,
              color: logoRed,
            ),
            const SizedBox(height: 24),
            Text(
              'Stay Updated',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: logoRed,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Get instant notifications about your construction project updates, site visits, and important milestones.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification permissions coming soon'),
                      backgroundColor: logoRed,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: logoRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Enable Notifications'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
