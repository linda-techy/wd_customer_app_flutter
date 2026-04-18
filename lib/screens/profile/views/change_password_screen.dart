import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../config/api_config.dart';
import '../../../constants.dart';
import '../../../route/route_constants.dart';
import '../../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const Color _brand = primaryColor;

  final _formKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  String? _currentPasswordError;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Clear any inline current-password error before re-validating
    setState(() => _currentPasswordError = null);

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
        '${ApiConfig.baseUrl}${ApiConfig.changePasswordEndpoint}',
        data: {
          'currentPassword': _currentPasswordCtrl.text,
          'newPassword': _newPasswordCtrl.text,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: successColor,
        ),
      );

      await AuthService.logoutWithApi();

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        entryPointScreenRoute,
        (route) => false,
      );
    } on DioException catch (e) {
      if (!mounted) return;

      final statusCode = e.response?.statusCode;
      final rawMsg = e.response?.data?['message']?.toString() ?? '';

      if (statusCode == 400 &&
          rawMsg.toLowerCase().contains('current password is incorrect')) {
        setState(() {
          _currentPasswordError = 'Current password is incorrect';
          _isLoading = false;
        });
        // Re-validate to surface the inline error
        _formKey.currentState!.validate();
        return;
      }

      final displayMsg = rawMsg.isNotEmpty
          ? rawMsg
          : (e.message ?? 'Failed to change password');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(displayMsg), backgroundColor: errorColor),
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
        title: const Text('Change Password'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _brand.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _brand.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: _brand, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'After changing your password you will be signed out and need to log in again.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              _buildPasswordField(
                controller: _currentPasswordCtrl,
                label: 'Current Password *',
                show: _showCurrent,
                onToggle: () => setState(() => _showCurrent = !_showCurrent),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Current password is required';
                  if (_currentPasswordError != null) return _currentPasswordError;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildPasswordField(
                controller: _newPasswordCtrl,
                label: 'New Password *',
                show: _showNew,
                onToggle: () => setState(() => _showNew = !_showNew),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'New password is required';
                  if (v.length < 8) return 'Password must be at least 8 characters';
                  if (v == _currentPasswordCtrl.text) {
                    return 'New password must differ from current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildPasswordField(
                controller: _confirmPasswordCtrl,
                label: 'Confirm New Password *',
                show: _showConfirm,
                onToggle: () => setState(() => _showConfirm = !_showConfirm),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please confirm your new password';
                  if (v != _newPasswordCtrl.text) return 'Passwords do not match';
                  return null;
                },
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
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Change Password',
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool show,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !show,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: _brand, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: blackColor60,
            size: 20,
          ),
          onPressed: onToggle,
        ),
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
