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
    super.key,
    required this.projectId,
    required this.packageDetails,
    required this.sqFeet,
  });

  @override
  State<DesignPackagePaymentScreen> createState() =>
      _DesignPackagePaymentScreenState();
}

class _DesignPackagePaymentScreenState
    extends State<DesignPackagePaymentScreen> {
  bool _isSubmitting = false;
  bool _isCustomPayment = false;
  String? _selectedPaymentMethod = 'Online';
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
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
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
        InkWell(
          onTap: () {
            setState(() {
              _isCustomPayment = false;
              _selectedPaymentMethod = 'Online';
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: !_isCustomPayment ? AppColors.primary : Colors.grey.shade300,
                width: !_isCustomPayment ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              color: !_isCustomPayment ? AppColors.primary.withOpacity(0.05) : null,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(
                        !_isCustomPayment ? Icons.check_circle : Icons.circle_outlined,
                        color: !_isCustomPayment ? AppColors.primary : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
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
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        InkWell(
          onTap: () {
            setState(() {
              _isCustomPayment = true;
              _selectedPaymentMethod = null;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isCustomPayment ? AppColors.primary : Colors.grey.shade300,
                width: _isCustomPayment ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              color: _isCustomPayment ? AppColors.primary.withOpacity(0.05) : null,
            ),
            child: Row(
              children: [
                Icon(
                  _isCustomPayment ? Icons.check_circle : Icons.circle_outlined,
                  color: _isCustomPayment ? AppColors.primary : Colors.grey,
                ),
                const SizedBox(width: 12),
                Text(
                  'Pay in installment',
                  style: AppTypography.bodyLarge(context).copyWith(
                    fontWeight: _isCustomPayment ? FontWeight.bold : FontWeight.normal,
                    color: _isCustomPayment ? AppColors.primary : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (_isCustomPayment) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Payment Schedule',
            style: AppTypography.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          'Sl.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall(context).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Activity',
                          style: AppTypography.bodySmall(context).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 100,
                        child: Text(
                          '% Split',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall(context).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 100,
                        child: Text(
                          'Amount',
                          textAlign: TextAlign.right,
                          style: AppTypography.bodySmall(context).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                ...[
                  'At the time of appointment as advance',
                  'On finalizing preliminary designs, prior to VR walkthrough and submission of drawings for statutory approvals',
                  'Before starting interior design phase',
                ].asMap().entries.map((entry) {
                  final idx = entry.key;
                  final activity = entry.value;
                  // Calculate amount based on total project value (No discount + 18% GST)
                  final priceString = widget.packageDetails['price'] as String;
                  final pricePerSqFt = double.tryParse(
                          priceString.replaceAll(RegExp(r'[^0-9.]'), '').split('.').first) ??
                      0.0;
                  
                  final totalBasePrice = pricePerSqFt * widget.sqFeet;
                  final totalWithGst = totalBasePrice * 1.18;
                  final stageAmount = totalWithGst / 3;
                  
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${idx + 1}',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall(context),
                          ),
                        ),
                        Expanded(
                          child: Text(activity, style: AppTypography.bodySmall(context)),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 100,
                          child: Text(
                            '33.33%',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall(context).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 100,
                          child: Text(
                            _currencyFormat.format(stageAmount),
                            textAlign: TextAlign.right,
                            style: AppTypography.bodySmall(context).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 40), // Empty Sl.
                      Expanded(
                        child: Text(
                          'Total',
                          style: AppTypography.bodySmall(context).copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 100,
                        child: Text(
                          '100%',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall(context).copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 100,
                        child: Text(
                          _currencyFormat.format(_basePrice * 1.18),
                          textAlign: TextAlign.right,
                          style: AppTypography.bodySmall(context).copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '* The payment schedule is split into 3 equal installments (33.33% each). The amount is calculated as: (Base Rate + 18% GST) / 3.',
            style: AppTypography.bodySmall(context).copyWith(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],

        if (!_isCustomPayment) ...[
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
                child: _buildPaymentMethodCard('Online'),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildPaymentMethodCard('Cash'),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildPaymentMethodCard('Cheque'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
            ),
            child: const Text('Apply Promo Code'),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentMethodCard(String title) {
    final isSelected = _selectedPaymentMethod == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
