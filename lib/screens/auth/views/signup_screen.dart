import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'components/sign_up_form.dart';
import '../../../route/route_constants.dart';
import '../../../services/auth_service.dart';
import '../../../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isLoading = false;
  bool _agreedToTerms = false;

  Future<void> _handleSignUp() async {
    // Validation
    if (_name.trim().isEmpty) {
      _showError('Please enter your full name');
      return;
    }
    if (_email.trim().isEmpty) {
      _showError('Please enter your email address');
      return;
    }
    if (_password.isEmpty) {
      _showError('Please enter a password');
      return;
    }
    if (_password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (_password != _confirmPassword) {
      _showError('Passwords do not match');
      return;
    }
    if (!_agreedToTerms) {
      _showError('Please agree to the Terms of Service & Privacy Policy');
      return;
    }

    // Parse first and last name
    final nameParts = _name.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.registerWithApi(
        firstName,
        lastName.isEmpty ? firstName : lastName,
        _email.trim(),
        _password,
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Welcome!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          entryPointScreenRoute,
          (route) => false,
        );
      } else {
        _showError(response.error?.message ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showError('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: logoRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/signUp_dark.png",
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let's get started!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Please enter your valid data in order to create an account.",
                  ),
                  const SizedBox(height: defaultPadding),
                  SignUpForm(
                    onNameChanged: (name) {
                      _name = name;
                    },
                    onEmailChanged: (email) {
                      _email = email;
                    },
                    onPasswordChanged: (password) {
                      _password = password;
                    },
                    onConfirmPasswordChanged: (confirmPassword) {
                      _confirmPassword = confirmPassword;
                    },
                    onSignUp: _handleSignUp,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      Checkbox(
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        value: _agreedToTerms,
                        activeColor: logoRed,
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "I agree with the",
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(
                                        context, termsOfServicesScreenRoute);
                                  },
                                text: " Terms of service ",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(
                                text: "& privacy policy.",
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Do you have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, logInScreenRoute);
                        },
                        child: const Text("Log in"),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
