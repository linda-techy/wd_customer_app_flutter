import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../config/api_config.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';

class EditUserInfoScreen extends StatefulWidget {
  const EditUserInfoScreen({super.key});

  @override
  State<EditUserInfoScreen> createState() => _EditUserInfoScreenState();
}

class _EditUserInfoScreenState extends State<EditUserInfoScreen> {
  static const Color _brand = primaryColor;

  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();

  String _email = '';
  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _addressCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await AuthService.getUserInfo();
    if (userInfo != null && mounted) {
      setState(() {
        _firstNameCtrl.text = userInfo.firstName;
        _lastNameCtrl.text = userInfo.lastName;
        _phoneCtrl.text = userInfo.phone;
        _whatsappCtrl.text = userInfo.whatsappNumber;
        _addressCtrl.text = userInfo.address;
        _companyCtrl.text = userInfo.companyName;
        _email = userInfo.email;
        _isFetching = false;
      });
    } else {
      // Fallback to basic user data
      final user = await AuthService.getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          _email = user.email;
          // Split name into first/last as best-effort
          final parts = user.name.split(' ');
          _firstNameCtrl.text = parts.isNotEmpty ? parts.first : '';
          _lastNameCtrl.text =
              parts.length > 1 ? parts.sublist(1).join(' ') : '';
          _isFetching = false;
        });
      } else if (mounted) {
        setState(() => _isFetching = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final token = await AuthService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final dio = Dio(BaseOptions(
        connectTimeout: ApiConfig.connectionTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
      ));
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['Content-Type'] = 'application/json';

      await dio.put(
        '${ApiConfig.baseUrl}${ApiConfig.updateProfileEndpoint}',
        data: {
          'firstName': _firstNameCtrl.text.trim(),
          'lastName': _lastNameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'whatsappNumber': _whatsappCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'companyName': _companyCtrl.text.trim(),
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: successColor,
        ),
      );
      Navigator.pop(context);
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ?? e.message ?? 'Failed to update profile';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString()), backgroundColor: errorColor),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: errorColor),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator(color: _brand))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email read-only banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _brand.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _brand.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.email_outlined,
                              color: _brand, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _email.isNotEmpty ? _email : 'No email on file',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const Text(
                            'Read only',
                            style: TextStyle(
                                fontSize: 11,
                                color: blackColor60,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader('Personal Information',
                        Icons.person_outline),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _firstNameCtrl,
                      label: 'First Name *',
                      hint: 'Enter first name',
                      icon: Icons.badge_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'First name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _lastNameCtrl,
                      label: 'Last Name *',
                      hint: 'Enter last name',
                      icon: Icons.badge_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Last name is required'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader('Contact Details', Icons.contact_phone_outlined),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _phoneCtrl,
                      label: 'Phone *',
                      hint: 'e.g. +91 9876543210',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Phone number is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _whatsappCtrl,
                      label: 'WhatsApp Number (Optional)',
                      hint: 'e.g. +91 9876543210',
                      icon: Icons.chat_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _addressCtrl,
                      label: 'Address (Optional)',
                      hint: 'Enter your address',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader(
                        'Business Information', Icons.business_outlined),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _companyCtrl,
                      label: 'Company Name (Optional)',
                      hint: 'Enter company name',
                      icon: Icons.apartment_outlined,
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brand,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                        ),
                        onPressed: _isLoading ? null : _save,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
