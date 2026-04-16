import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../../config/api_config.dart';
import '../../../constants.dart';
import '../../leads/my_referrals_screen.dart';

/// Comprehensive Refer a Friend screen.
/// Submits a referral lead to the portal API's public /leads/referral endpoint.
/// No authentication required — available to all customers.
class ReferAFriendScreen extends StatefulWidget {
  const ReferAFriendScreen({super.key});

  @override
  State<ReferAFriendScreen> createState() => _ReferAFriendScreenState();
}

class _ReferAFriendScreenState extends State<ReferAFriendScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // ── Referrer (your info) ────────────────────────────────────────────────
  final _yourNameCtrl = TextEditingController();
  final _yourEmailCtrl = TextEditingController();
  final _yourPhoneCtrl = TextEditingController();
  final _yourRelationCtrl = TextEditingController();

  // ── Referred person ─────────────────────────────────────────────────────
  final _referralNameCtrl = TextEditingController();
  final _referralEmailCtrl = TextEditingController();
  final _referralPhoneCtrl = TextEditingController();
  final _referralLocationCtrl = TextEditingController();

  // ── Project details ──────────────────────────────────────────────────────
  String _projectType = '';
  String _estimatedBudget = '';
  String _timeline = '';
  final _messageCtrl = TextEditingController();

  bool _isSubmitting = false;
  bool _submitted = false;
  String? _errorMessage;

  static const Color _brand = Color(0xFFD84940);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _yourNameCtrl.dispose();
    _yourEmailCtrl.dispose();
    _yourPhoneCtrl.dispose();
    _yourRelationCtrl.dispose();
    _referralNameCtrl.dispose();
    _referralEmailCtrl.dispose();
    _referralPhoneCtrl.dispose();
    _referralLocationCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  // ── Validators ────────────────────────────────────────────────────────────

  String? _requiredValidator(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
      return 'Enter a valid 10-digit Indian mobile number';
    }
    return null;
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return null; // optional
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_projectType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a project type'),
          backgroundColor: _brand,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final body = {
      'yourName': _yourNameCtrl.text.trim(),
      'yourEmail': _yourEmailCtrl.text.trim(),
      'yourPhone': _yourPhoneCtrl.text.replaceAll(RegExp(r'\D'), ''),
      'referralName': _referralNameCtrl.text.trim(),
      'referralEmail': _referralEmailCtrl.text.trim(),
      'referralPhone': _referralPhoneCtrl.text.replaceAll(RegExp(r'\D'), ''),
      'projectType': _projectType,
      'estimatedBudget': _estimatedBudget,
      'location': _referralLocationCtrl.text.trim(),
      'message': _buildMessage(),
    };

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));
      final url = '${ApiConfig.portalApiBaseUrl}/leads/referral';
      final response = await dio.post(
        url,
        data: body,
        options: Options(
          contentType: 'application/json',
          headers: {'Accept': 'application/json'},
          validateStatus: (_) => true,
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = response.data as Map<String, dynamic>?;
        if (json?['success'] == true) {
          setState(() => _submitted = true);
          return;
        }
      }

      // Extract backend error message
      String msg = 'Submission failed. Please try again.';
      try {
        final json = response.data as Map<String, dynamic>?;
        if (json?['message'] != null) msg = json!['message'] as String;
      } catch (_) {}
      setState(() => _errorMessage = msg);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        setState(() => _errorMessage = 'No internet connection. Please check your network.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.sendTimeout) {
        setState(() => _errorMessage = 'Request timed out. Please try again.');
      } else {
        setState(() => _errorMessage = 'Something went wrong. Please try again.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _buildMessage() {
    final parts = <String>[];
    if (_yourRelationCtrl.text.trim().isNotEmpty) {
      parts.add('Relation to referral: ${_yourRelationCtrl.text.trim()}');
    }
    if (_timeline.isNotEmpty) {
      parts.add('Expected timeline: $_timeline');
    }
    if (_messageCtrl.text.trim().isNotEmpty) {
      parts.add(_messageCtrl.text.trim());
    }
    return parts.join('\n');
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Refer a Friend'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'New Referral'),
            Tab(text: 'My Referrals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _submitted ? _buildSuccessView() : _buildFormView(),
          const MyReferralsScreen(),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'Referral Submitted!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Thank you for referring your friend. Our team will reach out to them soon. You\'ll be notified when your reward is processed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Profile', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Rewards banner ──────────────────────────────────────────
            _buildRewardsBanner(),
            const SizedBox(height: 24),

            // ── Error ────────────────────────────────────────────────────
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Section: Your Information ────────────────────────────────
            _buildSectionHeader('Your Information', Icons.person),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _yourNameCtrl,
              label: 'Your Name *',
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              validator: (v) => _requiredValidator(v, 'Your name'),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _yourPhoneCtrl,
              label: 'Your Mobile Number *',
              hint: '10-digit mobile number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              validator: _phoneValidator,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _yourEmailCtrl,
              label: 'Your Email (Optional)',
              hint: 'your@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _yourRelationCtrl,
              label: 'Your Relation to Friend (Optional)',
              hint: 'e.g. Colleague, Neighbour, Friend',
              icon: Icons.people_outline,
            ),
            const SizedBox(height: 28),

            // ── Section: Friend's Information ────────────────────────────
            _buildSectionHeader("Friend's Information", Icons.person_add),
            const SizedBox(height: 4),
            Text(
              'Tell us about the person who is planning to build',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _referralNameCtrl,
              label: "Friend's Name *",
              hint: "Enter friend's full name",
              icon: Icons.badge_outlined,
              validator: (v) => _requiredValidator(v, "Friend's name"),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _referralPhoneCtrl,
              label: "Friend's Mobile Number *",
              hint: '10-digit mobile number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              validator: _phoneValidator,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _referralEmailCtrl,
              label: "Friend's Email (Optional)",
              hint: "friend@email.com",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _referralLocationCtrl,
              label: 'Location / District *',
              hint: 'e.g. Thrissur, Ernakulam, Kozhikode',
              icon: Icons.location_on_outlined,
              validator: (v) => _requiredValidator(v, 'Location'),
            ),
            const SizedBox(height: 28),

            // ── Section: Project Details ─────────────────────────────────
            _buildSectionHeader('Project Details', Icons.construction),
            const SizedBox(height: 4),
            Text(
              "Help us understand your friend's requirements",
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Project Type *',
              value: _projectType.isEmpty ? null : _projectType,
              icon: Icons.home_work_outlined,
              items: const [
                DropdownMenuItem(value: 'residential', child: Text('Residential Home')),
                DropdownMenuItem(value: 'villa', child: Text('Luxury Villa')),
                DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                DropdownMenuItem(value: 'commercial', child: Text('Commercial / Office')),
                DropdownMenuItem(value: 'renovation', child: Text('Renovation / Extension')),
                DropdownMenuItem(value: 'plot_development', child: Text('Plot Development')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => _projectType = v ?? ''),
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Estimated Budget',
              value: _estimatedBudget.isEmpty ? null : _estimatedBudget,
              icon: Icons.currency_rupee,
              items: const [
                DropdownMenuItem(value: '15-25', child: Text('₹15 – 25 Lakhs')),
                DropdownMenuItem(value: '25-50', child: Text('₹25 – 50 Lakhs')),
                DropdownMenuItem(value: '50-75', child: Text('₹50 – 75 Lakhs')),
                DropdownMenuItem(value: '75-100', child: Text('₹75 Lakhs – 1 Crore')),
                DropdownMenuItem(value: '100+', child: Text('Above ₹1 Crore')),
              ],
              onChanged: (v) => setState(() => _estimatedBudget = v ?? ''),
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Expected Timeline',
              value: _timeline.isEmpty ? null : _timeline,
              icon: Icons.calendar_today_outlined,
              items: const [
                DropdownMenuItem(value: 'asap', child: Text('As soon as possible')),
                DropdownMenuItem(value: '3_months', child: Text('Within 3 months')),
                DropdownMenuItem(value: '6_months', child: Text('Within 6 months')),
                DropdownMenuItem(value: '1_year', child: Text('Within a year')),
                DropdownMenuItem(value: 'planning', child: Text('Still planning')),
              ],
              onChanged: (v) => setState(() => _timeline = v ?? ''),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _messageCtrl,
              label: 'Additional Notes (Optional)',
              hint: 'Any other details that may help our team...',
              icon: Icons.notes_outlined,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // ── Terms note ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _brand.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _brand.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: _brand, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Cash reward of ₹10,000–₹50,000 is credited 30–45 days after project foundation completion. Minimum project value: ₹15 Lakhs.',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Submit Referral', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD84940), Color(0xFFE57373)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _brand.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.card_giftcard, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Earn ₹10,000 – ₹50,000',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Refer someone building a home in Kerala',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _BenefitChip(icon: Icons.people, label: 'No Limit'),
              SizedBox(width: 8),
              _BenefitChip(icon: Icons.timer, label: '30–45 Day Payout'),
              SizedBox(width: 8),
              _BenefitChip(icon: Icons.verified, label: 'Trusted'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _brand, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _brand, size: 20),
        filled: true,
        fillColor: Theme.of(context).cardTheme.color ?? Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _brand, size: 20),
        filled: true,
        fillColor: Theme.of(context).cardTheme.color ?? Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brand, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
