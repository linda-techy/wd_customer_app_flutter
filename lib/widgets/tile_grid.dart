import 'package:flutter/material.dart';
import '../constants.dart';
import '../utils/responsive.dart';

class TileGrid extends StatelessWidget {
  final List<TileData> tiles;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;

  const TileGrid({
    super.key,
    required this.tiles,
    this.crossAxisCount = 3,
    this.childAspectRatio = 1.0,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);
    final int actualCrossAxisCount = isDesktop ? crossAxisCount : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: actualCrossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return TileCard(
          title: tile.title,
          icon: tile.icon,
          color: tile.color,
          onTap: tile.onTap,
          showBadge: tile.showBadge,
          badgeCount: tile.badgeCount,
          subtitle: tile.subtitle,
        );
      },
    );
  }
}

class TileCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool showBadge;
  final int? badgeCount;
  final String? subtitle;

  const TileCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
    this.showBadge = false,
    this.badgeCount,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isDesktop = Responsive.isDesktop(context);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(ResponsiveSpacing.getCardPadding(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with badge
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: isDesktop ? 28 : 24,
                    ),
                  ),
                  if (showBadge && badgeCount != null && badgeCount! > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: logoRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeCount.toString(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: ResponsiveFontSize.getBody(context) - 1,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: ResponsiveFontSize.getBody(context) - 2,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TileData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool showBadge;
  final int? badgeCount;
  final String? subtitle;

  TileData({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
    this.showBadge = false,
    this.badgeCount,
    this.subtitle,
  });
}

// Predefined tile configurations for common project features
class ProjectTiles {
  static List<TileData> getDefaultTiles(BuildContext context) {
    return [
      TileData(
        title: 'Documents',
        icon: Icons.folder,
        color: logoRed,
        subtitle: 'Floor Plans, Drawings',
        onTap: () {
          // Navigate to documents
        },
      ),
      TileData(
        title: '3D Design',
        icon: Icons.view_in_ar,
        color: logoGreyDark,
        subtitle: 'Virtual Tour',
        onTap: () {
          // Navigate to 3D design
        },
      ),
      TileData(
        title: 'Quality Check',
        icon: Icons.check_circle,
        color: logoGreyLight,
        subtitle: 'Inspections',
        showBadge: true,
        badgeCount: 3,
        onTap: () {
          // Navigate to QC
        },
      ),
      TileData(
        title: 'Project Activity',
        icon: Icons.timeline,
        color: logoPink,
        subtitle: 'Timeline',
        onTap: () {
          // Navigate to activity
        },
      ),
      TileData(
        title: '360° View',
        icon: Icons.threesixty,
        color: logoRed,
        subtitle: 'Virtual Tour',
        onTap: () {
          // Navigate to 360 view
        },
      ),
      TileData(
        title: 'Surveillance',
        icon: Icons.videocam,
        color: logoGreyDark,
        subtitle: 'Live Cameras',
        onTap: () {
          // Navigate to surveillance
        },
      ),
      TileData(
        title: 'Project Info',
        icon: Icons.info,
        color: logoGreyLight,
        subtitle: 'Details',
        onTap: () {
          // Navigate to project info
        },
      ),
      TileData(
        title: 'Project Summary',
        icon: Icons.summarize,
        color: logoPink,
        subtitle: 'Milestones',
        onTap: () {
          // Navigate to summary
        },
      ),
      TileData(
        title: 'Queries',
        icon: Icons.help,
        color: logoRed,
        subtitle: 'Support',
        showBadge: true,
        badgeCount: 2,
        onTap: () {
          // Navigate to queries
        },
      ),
      TileData(
        title: 'Gallery',
        icon: Icons.photo_library,
        color: logoGreyDark,
        subtitle: 'Photos',
        onTap: () {
          // Navigate to gallery
        },
      ),
      TileData(
        title: 'Payments',
        icon: Icons.payment,
        color: logoGreyLight,
        subtitle: 'Invoices',
        onTap: () {
          // Navigate to payments
        },
      ),
      TileData(
        title: 'BOQ',
        icon: Icons.list_alt,
        color: logoPink,
        subtitle: 'Bill of Quantities',
        onTap: () {
          // Navigate to BOQ
        },
      ),
    ];
  }
}
