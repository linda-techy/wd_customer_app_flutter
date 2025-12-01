import 'package:flutter/material.dart';
import '../../../design_tokens/app_colors.dart';
import '../../../design_tokens/app_spacing.dart';
import '../../../design_tokens/app_typography.dart';
import '../../../responsive/responsive_builder.dart';
import '../../../models/api_models.dart';
import '../../../services/dashboard_service.dart';
import 'design_package_payment_screen.dart';

class DesignPackageSelectionScreen extends StatefulWidget {
  const DesignPackageSelectionScreen({
    super.key,
    required this.projectId,
    required this.sqFeet,
  });

  final String projectId;
  final double sqFeet;

  @override
  State<DesignPackageSelectionScreen> createState() =>
      _DesignPackageSelectionScreenState();
}

class _DesignPackageSelectionScreenState
    extends State<DesignPackageSelectionScreen> {
  String? _selectedPackage;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _packages = [
    {
      'id': 'custom',
      'name': 'Custom',
      'price': '₹ 95 per sq.ft. (+18% GST)',
      'priceValue': 95,
      'discount': 'Upto 10% OFF',
      'features': [
        'Design Program',
        'BPI ⓘ',
        'Room-wise Functionality Mapping',
        'Plan (3 Changes)',
        'Elevation (3 Changes)',
        'Sanction Drawings',
        'Detailed Project Costing (DPC)',
        '3D Elevation Renders',
        'VR Walkthroughs (2 Sessions)',
        'Structural Design',
        'Curated Solutions',
      ],
      'color': AppColors.primary,
    },
    {
      'id': 'premium',
      'name': 'Premium',
      'price': '₹ 140 per sq.ft. (+18% GST)',
      'priceValue': 140,
      'discount': 'Upto 15% OFF',
      'features': [
        'Design Program',
        'BPI ⓘ',
        'Room-wise Functionality Mapping',
        'Plan (3 Changes)',
        'Elevation (3 Changes)',
        'Sanction Drawings',
        'Detailed Project Costing (DPC)',
        '3D Elevation & Interior Renders',
        'VR Walkthroughs (2 Sessions)',
        'Detailed Interior Design',
        'Detailed Landscape Design',
        'Detailed Furniture Design',
        'Detailed Lighting Design',
        'Individual Space Planning',
        'Structural and MEP Design ⓘ',
        'Additional VR Walkthrough (After finalization of interior & landscape design)',
        'Curated Solutions',
      ],
      'color': AppColors.secondary,
    },
    {
      'id': 'bespoke',
      'name': 'Bespoke',
      'price': '₹ 240 per sq.ft. (+18% GST)',
      'priceValue': 240,
      'discount': 'Upto 15% OFF',
      'features': [
        'Design Program',
        'BPI ⓘ',
        'Room-wise Functionality Mapping',
        'Plan (Unlimited Changes)',
        'Elevation (Unlimited Changes)',
        'Sanction Drawings',
        'Detailed Project Costing (DPC)',
        '3D Elevation & Interior Renders',
        'VR Walkthroughs (Unlimited Sessions)',
        'Detailed Interior Design',
        'Detailed Landscape Design',
        'Detailed Furniture Design',
        'Detailed Lighting Design',
        'Individual Space Planning',
        'Structural and MEP Design ⓘ',
        'Additional VR Walkthrough (Unlimited)',
        'Curated Solutions',
        'Dedicated Design Team',
        'Site Supervision (Periodic)',
      ],
      'color': const Color(0xFFD4AF37), // Gold color
    },
  ];

  Future<void> _submitSelection() async {
    if (_selectedPackage == null) return;

    final selectedPkgDetails = _packages.firstWhere(
      (pkg) => pkg['name'] == _selectedPackage,
      orElse: () => {},
    );

    if (selectedPkgDetails.isEmpty) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DesignPackagePaymentScreen(
          projectId: widget.projectId,
          packageDetails: selectedPkgDetails,
          sqFeet: widget.sqFeet,
        ),
      ),
    );

    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Design Package'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ResponsiveBuilder(
        mobile: (context) => _buildContent(context),
        tablet: (context) => Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildContent(context),
          ),
        ),
        desktop: (context) => Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _buildContent(context),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _selectedPackage == null || _isSubmitting
                ? null
                : _submitSelection,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Next',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          'Choose the package that fits your vision',
          style: AppTypography.headlineSmall(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Select one of the options below to proceed with your design phase.',
          style: AppTypography.bodyMedium(context).copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        ..._packages.map((pkg) => _buildPackageCard(context, pkg)),
      ],
    );
  }

  Widget _buildPackageCard(BuildContext context, Map<String, dynamic> pkg) {
    final isSelected = _selectedPackage == pkg['name'];
    final color = pkg['color'] as Color;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackage = pkg['name'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg - 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pkg['name'],
                          style: AppTypography.titleLarge(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pkg['price'],
                          style: AppTypography.bodyMedium(context).copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (pkg['discount'] != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            pkg['discount'],
                            style: AppTypography.bodySmall(context).copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inclusions',
                    style: AppTypography.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...pkg['features'].map<Widget>((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.circle,
                                size: 6,
                                color: color.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: AppTypography.bodyMedium(context).copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
