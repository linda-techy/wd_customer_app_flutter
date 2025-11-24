import 'package:flutter/material.dart';
import '../../design_tokens/app_colors.dart';
import '../../design_tokens/app_spacing.dart';
import '../../design_tokens/app_typography.dart';
import '../../responsive/responsive_builder.dart';
import '../../models/api_models.dart';

/// Responsive project card that adapts to different screen sizes
///
/// **Responsive Behavior:**
/// - Mobile: Compact single-column layout
/// - Tablet: Enhanced layout with more details
/// - Desktop: Full-width with hover states
///
/// **Usage:**
/// ```dart
/// ResponsiveProjectCard(
///   project: myProject,
///   onTap: () => navigateToDetails(),
/// )
/// ```
class ResponsiveProjectCard extends StatelessWidget {
  final ProjectCard project;
  final VoidCallback? onTap;
  final bool showFullDetails;

  const ResponsiveProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.showFullDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context) => _MobileProjectCard(
        project: project,
        onTap: onTap,
      ),
      tablet: (context) => _TabletProjectCard(
        project: project,
        onTap: onTap,
        showFullDetails: showFullDetails,
      ),
      desktop: (context) => _DesktopProjectCard(
        project: project,
        onTap: onTap,
        showFullDetails: showFullDetails,
      ),
    );
  }
}

/// Mobile project card - compact layout
class _MobileProjectCard extends StatelessWidget {
  final ProjectCard project;
  final VoidCallback? onTap;

  const _MobileProjectCard({
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.elevation2,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: AppTypography.titleMedium(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(status: project.status),
                ],
              ),

              if (project.code.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Code: ${project.code}',
                  style: AppTypography.bodySmall(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.sm),

              // Location
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      project.location,
                      style: AppTypography.bodySmall(context).copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Progress
              Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Progress',
                    style: AppTypography.bodySmall(context).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${project.progress.toStringAsFixed(0)}%',
                    style: AppTypography.bodySmall(context).copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xs),

              LinearProgressIndicator(
                value: project.progress / 100.0,
                backgroundColor: AppColors.grey300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.getProgressColor(project.progress),
                ),
                minHeight: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tablet project card - enhanced layout
class _TabletProjectCard extends StatelessWidget {
  final ProjectCard project;
  final VoidCallback? onTap;
  final bool showFullDetails;

  const _TabletProjectCard({
    required this.project,
    this.onTap,
    this.showFullDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.elevation2,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // Left side - main info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            style: AppTypography.titleLarge(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusBadge(status: project.status),
                      ],
                    ),
                    if (project.code.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Code: ${project.code}',
                        style: AppTypography.bodyMedium(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            project.location,
                            style: AppTypography.bodyMedium(context).copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.lg),

              // Right side - progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${project.progress.toStringAsFixed(0)}%',
                      style: AppTypography.headlineSmall(context).copyWith(
                        color: AppColors.getProgressColor(project.progress),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: project.progress / 100.0,
                      backgroundColor: AppColors.grey300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.getProgressColor(project.progress),
                      ),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Desktop project card - full layout with hover states
class _DesktopProjectCard extends StatefulWidget {
  final ProjectCard project;
  final VoidCallback? onTap;
  final bool showFullDetails;

  const _DesktopProjectCard({
    required this.project,
    this.onTap,
    this.showFullDetails = false,
  });

  @override
  State<_DesktopProjectCard> createState() => _DesktopProjectCardState();
}

class _DesktopProjectCardState extends State<_DesktopProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Card(
          elevation: _isHovered ? AppSpacing.elevation3 : AppSpacing.elevation2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  // Left side - main info
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.project.name,
                                style: AppTypography.headlineSmall(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _StatusBadge(status: widget.project.status),
                          ],
                        ),
                        if (widget.project.code.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Project Code: ${widget.project.code}',
                            style: AppTypography.bodyLarge(context).copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                widget.project.location,
                                style:
                                    AppTypography.bodyLarge(context).copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.xl),

                  // Right side - progress and actions
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Progress: ',
                              style: AppTypography.bodyLarge(context).copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${widget.project.progress.toStringAsFixed(0)}%',
                              style: AppTypography.titleLarge(context).copyWith(
                                color: AppColors.getProgressColor(
                                    widget.project.progress),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        LinearProgressIndicator(
                          value: widget.project.progress / 100.0,
                          backgroundColor: AppColors.grey300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.getProgressColor(widget.project.progress),
                          ),
                          minHeight: 10,
                        ),
                        if (_isHovered) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Click to view details →',
                            style: AppTypography.bodyMedium(context).copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Status badge component
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: AppTypography.labelSmall(context).copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
