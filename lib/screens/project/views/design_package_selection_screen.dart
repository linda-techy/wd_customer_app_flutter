import 'package:flutter/material.dart';
import '../../../design_tokens/app_colors.dart';
import '../../../design_tokens/app_spacing.dart';
import '../../../design_tokens/app_typography.dart';
import '../../../responsive/responsive_builder.dart';
import '../../../models/api_models.dart';

class DesignPackageSelectionScreen extends StatefulWidget {
  const DesignPackageSelectionScreen({super.key, required this.projectId});

  final String projectId;

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
      'description': 'Tailored design for your specific needs.',
      'price': 'Contact for pricing',
      'features': [
        'Custom Floor Plans',
        '2D Elevations',
        'Basic 3D Views',
        'Standard Material Selection'
      ],
      'color': AppColors.primary,
    },
    {
      'id': 'premium',
      'name': 'Premium',
      'description': 'High-end design with premium finishes.',
      'price': 'Starts at \$5,000',
      'features': [
        'Everything in Custom',
        'Detailed 3D Walkthrough',
        'Interior Design Consultation',
        'Premium Material Selection',
        'Lighting Design'
      ],
      'color': AppColors.secondary,
    },
    {
      'id': 'bespoke',
      'name': 'Bespoke',
      'description': 'Luxury design with exclusive attention.',
      'price': 'Starts at \$10,000',
      'features': [
        'Everything in Premium',
        'Unlimited Revisions',
        'Dedicated Design Team',
        'VR Experience',
        'Luxury Material Sourcing',
        'Site Supervision'
      ],
      'color': const Color(0xFFD4AF37), // Gold color
    },
  ];

  Future<void> _submitSelection() async {
    if (_selectedPackage == null) return;

    setState(() {
      _isSubmitting = true;
    });

    // TODO: Implement API call to save selection
    // For now, simulate a delay and go back
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected $_selectedPackage package'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context, _selectedPackage);
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
                    'Confirm Selection',
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
                        Text(
                          pkg['price'],
                          style: AppTypography.bodySmall(context).copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                    pkg['description'],
                    style: AppTypography.bodyMedium(context),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  ...pkg['features'].map<Widget>((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              size: 16,
                              color: color,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: AppTypography.bodySmall(context),
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
