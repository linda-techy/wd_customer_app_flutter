import 'package:flutter/material.dart';
import '../../../design_tokens/app_colors.dart';
import '../../../design_tokens/app_spacing.dart';
import '../../../design_tokens/app_typography.dart';
import '../../../services/dashboard_service.dart';
import '../../../responsive/responsive_builder.dart';
import 'package:intl/intl.dart';

class DesignPackagePaymentScreen extends StatefulWidget {
  final String projectId;
  final Map<String, dynamic> packageDetails;
  final double sqFeet;

  const DesignPackagePaymentScreen({
    Key? key,
    required this.projectId,
    required this.packageDetails,
    required this.sqFeet,
  }) : super(key: key);

  @override
  State<DesignPackagePaymentScreen> createState() =>
      _DesignPackagePaymentScreenState();
}

class _DesignPackagePaymentScreenState
    extends State<DesignPackagePaymentScreen> {
  bool _isSubmitting = false;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  double get _basePrice {
    // Extract price per sq ft from string (e.g. "₹ 95 per sq.ft.")
    final priceString = widget.packageDetails['price'] as String;
    final pricePerSqFt = double.tryParse(
            priceString.replaceAll(RegExp(r'[^0-9.]'), '').split('.').first) ??
        0.0;
    return pricePerSqFt * widget.sqFeet;
  }

  double get _discountAmount {
    // 10% for Custom, 15% for others
    final packageName = widget.packageDetails['name'].toString().toLowerCase();
    final discountPercent = packageName == 'custom' ? 0.10 : 0.15;
    return _basePrice * discountPercent;
  }

  double get _discountedPrice => _basePrice - _discountAmount;

  double get _gstAmount => _discountedPrice * 0.18;

  double get _totalAmount => _discountedPrice + _gstAmount;

  Future<void> _signAgreement() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await DashboardService.updateDesignPackage(
        widget.projectId,
        widget.packageDetails['name'],
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Design package "${widget.packageDetails['name']}" confirmed!'),
              backgroundColor: AppColors.success,
            ),
          );
          // Navigate back to project details (pop twice)
          Navigator.of(context)
            ..pop()
            ..pop(widget.packageDetails['name']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(response.error?.message ?? 'Failed to confirm package'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
            onPressed: _isSubmitting ? null : _signAgreement,
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
                    'Sign Agreement',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final color = widget.packageDetails['color'] as Color;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Package Inclusions Card
        Text(
          'Package Inclusions',
          style: AppTypography.titleMedium(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...(widget.packageDetails['features'] as List<String>)
                  .map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Icon(
                                Icons.circle,
                                size: 6,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: AppTypography.bodyMedium(context).copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Payment Options
        Text(
          'Payment Options',
          style: AppTypography.titleMedium(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay in full',
                          style: AppTypography.titleMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${(widget.packageDetails['name'].toString().toLowerCase() == 'custom' ? 10 : 15)}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _currencyFormat.format(_totalAmount),
                          style: AppTypography.titleLarge(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_currencyFormat.format(_basePrice * 1.18)} (incl. 18% GST)',
                          style: AppTypography.bodySmall(context).copyWith(
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Text(
            'Customize payment',
            style: AppTypography.bodyLarge(context),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Payment Methods
        Text(
          'Payment Methods',
          style: AppTypography.titleMedium(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodCard('Online', true),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildPaymentMethodCard('Cash', false),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildPaymentMethodCard('Cheque', false),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: () {},
          child: const Text('Apply Promo Code'),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
