import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/auth_guard.dart';
import '../../dashboard/views/customer_dashboard_screen.dart';
import '../../auth/views/guest_welcome_screen.dart';
import '../../auth/views/login_screen.dart';
import '../../auth/views/password_recovery_screen.dart';

enum _AuthStep { guest, login, forgotPassword }

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  bool isLoggedIn = false;
  bool isLoading = true;
  _AuthStep _authStep = _AuthStep.guest;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    setState(() {
      isLoggedIn = loggedIn;
      isLoading = false;
      if (loggedIn) _authStep = _AuthStep.guest;
    });
  }

  void _onLoginSuccess() {
    // Refresh auth state; the logged-in pages will be shown by the dashboard
    _checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!isLoggedIn) {
      switch (_authStep) {
        case _AuthStep.login:
          return LoginScreen(
            onLoginSuccess: _onLoginSuccess,
            onForgotPassword: () =>
                setState(() => _authStep = _AuthStep.forgotPassword),
          );
        case _AuthStep.forgotPassword:
          return PasswordRecoveryScreen(
            onBackToLogin: () =>
                setState(() => _authStep = _AuthStep.login),
          );
        case _AuthStep.guest:
          return GuestWelcomeScreen(
            onLoginPressed: () =>
                setState(() => _authStep = _AuthStep.login),
          );
      }
    }

    // Show customer dashboard when logged in with auth guard
    return const AuthGuard(
      child: CustomerDashboardScreen(),
    );
  }
}
