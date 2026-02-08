import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants.dart';
import '../../../components/animations/fade_entry.dart';
import '../../../components/animations/hover_card.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // State for preferences
  bool _analyticsEnabled = true;
  bool _personalizationEnabled = false;
  bool _marketingEnabled = false;
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text(
          "Settings & Cookies",
          style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: blackColor),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _analyticsEnabled = true;
                _personalizationEnabled = false;
                _marketingEnabled = false;
                _pushNotifications = true;
                _emailNotifications = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to default')),
              );
            },
            child: const Text("Reset", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            _buildSectionHeader("Privacy Preferences", Icons.privacy_tip_outlined),
            const SizedBox(height: defaultPadding),
            FadeEntry(
              delay: 100.ms,
              child: _buildSettingsGroup([
                _buildSwitchTile(
                  "Analytics Cookies",
                  "Help us improve by collecting anonymous usage data.",
                  Icons.analytics_outlined,
                  Colors.blue,
                  _analyticsEnabled,
                  (val) => setState(() => _analyticsEnabled = val),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  "Personalization",
                  "Customize content based on your interests.",
                  Icons.tune,
                  Colors.purple,
                  _personalizationEnabled,
                  (val) => setState(() => _personalizationEnabled = val),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  "Marketing",
                  "Allow relevant offers and promotions.",
                  Icons.campaign_outlined,
                  Colors.orange,
                  _marketingEnabled,
                  (val) => setState(() => _marketingEnabled = val),
                ),
              ]),
            ),

            const SizedBox(height: defaultPadding * 2),
            _buildSectionHeader("Notifications", Icons.notifications_none),
            const SizedBox(height: defaultPadding),
            FadeEntry(
              delay: 200.ms,
              child: _buildSettingsGroup([
                _buildSwitchTile(
                  "Push Notifications",
                  "Receive updates about your project progress.",
                  Icons.notifications_active_outlined,
                  primaryColor,
                  _pushNotifications,
                  (val) => setState(() => _pushNotifications = val),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  "Email Updates",
                  "Get weekly digests and invoices via email.",
                  Icons.mail_outline,
                  Colors.teal,
                  _emailNotifications,
                  (val) => setState(() => _emailNotifications = val),
                ),
              ]),
            ),

            const SizedBox(height: defaultPadding * 2),
            _buildSectionHeader("Advanced", Icons.settings_suggest_outlined),
            const SizedBox(height: defaultPadding),
            FadeEntry(
              delay: 300.ms,
              child: _buildSettingsGroup([
                _buildActionTile(
                  "Social Media Integration",
                  "Connect your accounts to share progress.",
                  Icons.share_outlined,
                  Colors.indigo,
                  () {},
                ),
                _buildDivider(),
                _buildActionTile(
                  "Delete Account",
                  "Permanently remove your data.",
                  Icons.delete_forever_outlined,
                  errorColor,
                  () {},
                  isDestructive: true,
                ),
              ]),
            ),
            const SizedBox(height: defaultPadding * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: blackColor60),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: blackColor60,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: blackColor.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: blackColor60,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return HoverCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20), // Helper to match container if needed
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDestructive ? errorColor : blackColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: blackColor60,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: isDestructive ? errorColor.withOpacity(0.5) : blackColor40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: lightGreyColor, indent: 60);
  }
}
