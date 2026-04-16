import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lead_models.dart';
import '../../providers/lead_provider.dart';

/// Displays the list of referrals this customer has made.
/// Each card shows the friend's name, project type, status badge, and date.
class MyReferralsScreen extends StatefulWidget {
  const MyReferralsScreen({super.key});

  @override
  State<MyReferralsScreen> createState() => _MyReferralsScreenState();
}

class _MyReferralsScreenState extends State<MyReferralsScreen> {
  static const Color _brand = Color(0xFFD84940);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<LeadProvider>().fetchMyReferrals(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeadProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.referrals.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final referrals = provider.referrals;

        if (referrals.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => context.read<LeadProvider>().fetchMyReferrals(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: referrals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildReferralCard(referrals[index]),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Referrals Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you refer a friend, their enquiry status will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCard(ReferralLead referral) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _brand.withOpacity(0.1),
                  child: Text(
                    referral.friendName.isNotEmpty
                        ? referral.friendName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: _brand,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        referral.friendName.isNotEmpty ? referral.friendName : 'Friend',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (referral.friendPhone.isNotEmpty)
                        Text(
                          referral.friendPhone,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                _buildStatusBadge(referral.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (referral.projectType.isNotEmpty) ...[
                  Icon(Icons.home_work_outlined, size: 15, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatProjectType(referral.projectType),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                ],
                if (referral.createdAt.isNotEmpty) ...[
                  Icon(Icons.calendar_today_outlined, size: 15, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(referral.createdAt),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Project Started':
        bg = Colors.green.withOpacity(0.1);
        fg = Colors.green;
        break;
      case 'Proposal Sent':
      case 'In Discussion':
        bg = Colors.blue.withOpacity(0.1);
        fg = Colors.blue;
        break;
      case 'Enquiry Closed':
        bg = Colors.grey.withOpacity(0.1);
        fg = Colors.grey;
        break;
      default:
        bg = Colors.orange.withOpacity(0.1);
        fg = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  String _formatProjectType(String type) {
    return type.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1)}';
    }).join(' ');
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
