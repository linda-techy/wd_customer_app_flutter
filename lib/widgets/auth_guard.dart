import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../route/route_constants.dart';
import '../screens/auth/views/guest_welcome_screen.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  final String? redirectRoute;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectRoute,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    setState(() {
      _isAuthenticated = isLoggedIn;
      _isLoading = false;
    });

    // If not authenticated, redirect to login after showing the screen
    if (!isLoggedIn && mounted) {
      // Show the beautiful login gate for 100ms before redirecting
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _handleLogin() {
    // Use root navigator so login works with nested MaterialApp
    Navigator.of(context, rootNavigator: true).pushReplacementNamed(
      widget.redirectRoute ?? logInScreenRoute,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE74C3C)),
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return GuestWelcomeScreen(
        onLoginPressed: _handleLogin,
      );
    }

    return widget.child;
  }
}
