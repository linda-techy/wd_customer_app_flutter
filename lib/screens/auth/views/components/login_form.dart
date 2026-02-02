import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../constants.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({
    super.key,
    required this.formKey,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    this.compact = false,
  });

  final GlobalKey<FormState> formKey;
  final Function(String) onEmailChanged;
  final Function(String) onPasswordChanged;
  final bool compact;

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Address Label
          Text(
            "Email Address",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color!
                  .withOpacity(0.8),
            ),
          ),
          SizedBox(height: widget.compact ? 4 : 8),
          TextFormField(
            onChanged: widget.onEmailChanged,
            onSaved: (email) {
              if (email != null) widget.onEmailChanged(email);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email address is required';
              }
              // Email validation regex
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: "Enter your email address",
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withOpacity(0.4),
              ),
              prefixIcon: Container(
                margin: EdgeInsets.only(right: widget.compact ? 8 : 12),
                padding: EdgeInsets.symmetric(horizontal: widget.compact ? 12 : 16),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.email_rounded,
                  size: widget.compact ? 20 : 22,
                  color: logoRed,
                ),
              ),
              filled: true,
              fillColor:
                  isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF5F6FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withOpacity(0.05),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: logoRed,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE53E3E),
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE53E3E),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: widget.compact ? 12 : 16,
              ),
            ),
          ),
          SizedBox(height: widget.compact ? 12 : 20),

          // Password Label
          Text(
            "Password",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .color!
                  .withOpacity(0.8),
            ),
          ),
          SizedBox(height: widget.compact ? 4 : 8),
          TextFormField(
            onChanged: widget.onPasswordChanged,
            onSaved: (password) {
              if (password != null) widget.onPasswordChanged(password);
            },
            validator: passwordValidator.call,
            obscureText: _obscurePassword,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: "Enter your password",
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withOpacity(0.4),
              ),
              prefixIcon: Container(
                margin: EdgeInsets.only(right: widget.compact ? 8 : 12),
                padding: EdgeInsets.symmetric(horizontal: widget.compact ? 12 : 16),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: widget.compact ? 20 : 22,
                  color: logoRed,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: widget.compact ? 20 : 22,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withOpacity(0.5),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor:
                  isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF5F6FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withOpacity(0.05),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: logoRed,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE53E3E),
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE53E3E),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: widget.compact ? 12 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
