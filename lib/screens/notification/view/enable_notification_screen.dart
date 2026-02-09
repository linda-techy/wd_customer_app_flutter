import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';

class EnableNotificationScreen extends StatefulWidget {
  const EnableNotificationScreen({super.key});

  @override
  State<EnableNotificationScreen> createState() => _EnableNotificationScreenState();
}

class _EnableNotificationScreenState extends State<EnableNotificationScreen> {
  bool _isEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEnabled = prefs.getBool('notifications_enabled') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _toggleNotifications() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final newState = !_isEnabled;
      await prefs.setBool('notifications_enabled', newState);
      setState(() {
        _isEnabled = newState;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newState
                ? 'Notifications enabled! You will receive project updates.'
                : 'Notifications disabled.'),
            backgroundColor: newState ? Colors.green : Colors.grey,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update notification settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: logoRed,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            const SizedBox(height: 40),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isEnabled ? Icons.notifications_active : Icons.notifications_off_outlined,
                key: ValueKey(_isEnabled),
                size: 80,
                color: _isEnabled ? Colors.green : logoRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isEnabled ? 'Notifications Active' : 'Stay Updated',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isEnabled ? Colors.green : logoRed,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              _isEnabled
                  ? 'You are receiving notifications about your construction project updates, site visits, and important milestones.'
                  : 'Enable notifications to get instant updates about your construction project, site visits, and important milestones.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Notification categories
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildNotificationCategory(
                    Icons.construction,
                    'Project Updates',
                    'Construction progress and milestone completions',
                  ),
                  const Divider(height: 24),
                  _buildNotificationCategory(
                    Icons.location_on,
                    'Site Visits',
                    'Upcoming site visit reminders and check-in alerts',
                  ),
                  const Divider(height: 24),
                  _buildNotificationCategory(
                    Icons.receipt_long,
                    'Billing & Payments',
                    'Invoice generation and payment confirmations',
                  ),
                  const Divider(height: 24),
                  _buildNotificationCategory(
                    Icons.photo_camera,
                    'Gallery Updates',
                    'New site photos and progress images',
                  ),
                ],
              ),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _toggleNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEnabled ? Colors.grey[600] : logoRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_isEnabled ? 'Disable Notifications' : 'Enable Notifications'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCategory(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isEnabled ? Colors.green.withOpacity(0.1) : logoRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _isEnabled ? Colors.green : logoRed, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: blackColor.withOpacity(0.6))),
            ],
          ),
        ),
        if (_isEnabled)
          const Icon(Icons.check_circle, color: Colors.green, size: 20)
        else
          Icon(Icons.circle_outlined, color: Colors.grey[400], size: 20),
      ],
    );
  }
}
