import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../route/screen_export.dart';
import '../../../widgets/auth_guard.dart';
import '../../dashboard/views/customer_dashboard_screen.dart';
import '../../auth/views/guest_welcome_screen.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  bool isLoggedIn = false;
  bool isLoading = true;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!isLoggedIn) {
      return GuestWelcomeScreen(
        onLoginPressed: () {
          // Use root navigator so login replaces the entire shell (works with nested MaterialApp)
          Navigator.of(context, rootNavigator: true).pushReplacementNamed(
            logInScreenRoute,
          );
        },
      );
    }

    // Show customer dashboard when logged in with auth guard
    return const AuthGuard(
      child: CustomerDashboardScreen(),
    );
  }
}
