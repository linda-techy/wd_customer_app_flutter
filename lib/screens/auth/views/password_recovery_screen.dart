import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  /// When provided, called when "Back to Login" is tapped instead of
  /// Navigator.pop(). Used when embedded inline inside the EntryPoint.
  final VoidCallback? onBackToLogin;

  const PasswordRecoveryScreen({super.key, this.onBackToLogin});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _emailController = TextEditingController();

  // 0 = enter email, 1 = check your email
  int _step = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email address');
      return;
    }

    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.forgotPassword(email);

      if (!mounted) return;

      // Always advance to the "check your email" step regardless of whether
      // the email exists — this prevents user enumeration.
      if (response.success) {
        setState(() => _step = 1);
      } else {
        _showError(response.error?.message ?? 'Failed to send reset link. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showError('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: logoRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: logoRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding * 1.5),
          child: _step == 0 ? _buildEmailStep() : _buildCheckEmailStep(),
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: logoRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline, size: 40, color: logoRed),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Forgot Password?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Enter the email address linked to your account and\nwe\'ll send you a secure reset link.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 36),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _sendResetLink(),
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'you@example.com',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: logoRed, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendResetLink,
            style: ElevatedButton.styleFrom(
              backgroundColor: logoRed,
              foregroundColor: Colors.white,
              disabledBackgroundColor: logoRed.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Send Reset Link',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: () {
              if (widget.onBackToLogin != null) {
                widget.onBackToLogin!();
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Back to Login',
              style: TextStyle(color: logoRed),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckEmailStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_outlined, size: 72, color: Colors.blue),
        ),
        const SizedBox(height: 32),
        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            children: [
              const TextSpan(text: 'A password reset link has been sent to\n'),
              TextSpan(
                text: _emailController.text.trim(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const TextSpan(
                text: '\n\nOpen the email and tap the reset link to set a new password. '
                    'The link expires in 15 minutes.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade700, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Can\'t find the email? Check your spam or junk folder.',
                  style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : _sendResetLink,
            style: OutlinedButton.styleFrom(
              foregroundColor: logoRed,
              side: const BorderSide(color: logoRed),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(logoRed),
                    ),
                  )
                : const Text(
                    'Resend Link',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              if (widget.onBackToLogin != null) {
                widget.onBackToLogin!();
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Back to Login',
              style: TextStyle(color: logoRed, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}
