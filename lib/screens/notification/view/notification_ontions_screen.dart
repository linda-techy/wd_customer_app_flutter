import 'package:flutter/material.dart';
import '../../../constants.dart';

class NotificationOptionsScreen extends StatelessWidget {
  const NotificationOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: logoRed,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.notifications, color: logoRed),
              title: const Text('Project Updates'),
              subtitle: const Text('Get notified about construction progress'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: logoRed,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.construction, color: logoRed),
              title: const Text('Site Visits'),
              subtitle: const Text('Notifications for scheduled site visits'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: logoRed,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: logoRed),
              title: const Text('Payment Reminders'),
              subtitle: const Text('Payment due dates and invoices'),
              trailing: Switch(
                value: false,
                onChanged: (value) {},
                activeColor: logoRed,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner, color: logoRed),
              title: const Text('Document Updates'),
              subtitle: const Text('New documents and approvals'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: logoRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
