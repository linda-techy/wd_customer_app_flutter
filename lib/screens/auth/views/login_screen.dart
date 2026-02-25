import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../route/route_constants.dart';
import '../../../services/auth_service.dart';
import '../../../utils/responsive.dart';

import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  /// When provided, called on successful login instead of navigating away.
  /// Used when the screen is embedded inside the EntryPoint (with bottom nav).
  final VoidCallback? onLoginSuccess;

  /// When provided, called when "Forgot Password?" is tapped instead of
  /// pushing a new route. Used for inline/embedded usage.
  final VoidCallback? onForgotPassword;

  const LoginScreen({super.key, this.onLoginSuccess, this.onForgotPassword});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Debug: Log login attempt (no sensitive data)
      debugPrint('Attempting login...');

      final response = await AuthService.loginWithApi(_email, _password);

      if (!mounted) return;

      // Debug: Log response status
      debugPrint('Login response:');
      debugPrint('Success: ${response.success}');
      debugPrint('Status Code: ${response.error?.statusCode}');

      if (response.success && response.data != null) {
        _showSuccessSnackBar('Login successful!');

        // If an inline callback is provided (e.g. embedded inside EntryPoint),
        // call it instead of pushing a new route so the bottom nav stays visible.
        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
          return;
        }

        // Check redirect URL from API response
        final redirectUrl = response.data!.redirectUrl;
        debugPrint('Login successful! Redirect URL: $redirectUrl');
        debugPrint('Project count: ${response.data!.projectCount}');

        // Navigate based on redirect URL
        if (redirectUrl == '/dashboard') {
          // Navigate directly to customer dashboard
          Navigator.pushNamedAndRemoveUntil(
            context,
            customerDashboardScreenRoute,
            ModalRoute.withName(logInScreenRoute),
          );
        } else {
          // Default navigation to main app with bottom navigation
          Navigator.pushNamedAndRemoveUntil(
            context,
            entryPointScreenRoute,
            ModalRoute.withName(logInScreenRoute),
          );
        }
      } else {
        String errorMessage =
            response.error?.message ?? 'Login failed. Please try again.';

        // Add more specific error handling
        if (response.error?.statusCode == 401) {
          errorMessage =
              'Invalid email or password. Please check your credentials and try again.';
        } else if (response.error?.statusCode == 0) {
          errorMessage =
              'Cannot connect to server. Please check your internet connection and try again.';
        } else if (response.error?.statusCode == 500) {
          errorMessage = 'Server error. Please try again later.';
        }

        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Login exception: $e');
        _showErrorDialog('An unexpected error occurred: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isTablet = Responsive.isTablet(context);
    final size = MediaQuery.sizeOf(context);
    final bool isSmallHeight = size.height < 720;
    final bool isVerySmallHeight = size.height < 600;

    // Responsive logo size
    final double logoSize = isDesktop
        ? 120
        : (isTablet
            ? (isVerySmallHeight ? 56 : (isSmallHeight ? 70 : 100))
            : (isVerySmallHeight ? 48 : (isSmallHeight ? 56 : 80)));
    final double headerPadding = isDesktop
        ? 60
        : (isTablet
            ? (isVerySmallHeight ? 12 : (isSmallHeight ? 20 : 50))
            : (isVerySmallHeight ? 10 : (isSmallHeight ? 16 : 40)));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ResponsiveContainer(
            maxWidth: 1200,
            child: Responsive(
              mobile: _buildMobileLayout(context, isDark, logoSize, headerPadding,
                  isSmallHeight, isVerySmallHeight, size),
              tablet: _buildMobileLayout(context, isDark, logoSize, headerPadding,
                  isSmallHeight, isVerySmallHeight, size),
              desktop: _buildDesktopLayout(context, isDark, size),
            ),
          ),
        ),
      ),
    );
  }

  // Mobile and Tablet Layout - no scroll, viewport-fit (same as Guest Welcome)
  Widget _buildMobileLayout(BuildContext context, bool isDark, double logoSize,
      double headerPadding, bool isSmallHeight, bool isVerySmallHeight, Size size) {
    final padding = ResponsiveSpacing.getPadding(context);
    final vPad = isVerySmallHeight ? 6.0 : (isSmallHeight ? 10.0 : padding * 0.4);
    final hPad = isVerySmallHeight ? 12.0 : (isSmallHeight ? 16.0 : padding);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: _buildHeader(context, isDark, logoSize, headerPadding, isVerySmallHeight),
                    ),
                    SizedBox(height: isVerySmallHeight ? 6 : (isSmallHeight ? 10 : 16)),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width - hPad * 2,
                      child: _buildLoginForm(context, isDark, isSmallHeight || isVerySmallHeight),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Desktop Layout (Two Column - Image + Form)
  Widget _buildDesktopLayout(BuildContext context, bool isDark, Size size) {
    return Row(
      children: [
        // Left Side - Branding
        Expanded(
          flex: 5,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1A1A2E),
                        const Color(0xFF16213E),
                      ]
                    : [
                        const Color(0xFF0F3460),
                        const Color(0xFF16213E),
                      ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Walldot Logo
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo/walldot_logo.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "WALLDOT BUILDERS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Building Your Dreams",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Right Side - Login Form (no scroll, viewport-fit)
        Expanded(
          flex: 5,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: _buildLoginForm(context, isDark, false),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Header Widget (for mobile/tablet) - overflow-safe with FittedBox
  Widget _buildHeader(BuildContext context, bool isDark, double logoSize,
      double headerPadding, bool isVerySmallHeight) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                ]
              : [
                  const Color(0xFF0F3460),
                  const Color(0xFF16213E),
                ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: headerPadding),
          // Walldot Logo with better visibility
          Container(
            padding: EdgeInsets.all(logoSize * 0.2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Image.asset(
              'assets/logo/walldot_logo.png',
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: isVerySmallHeight ? 12 : 24),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "WALLDOT BUILDERS",
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveFontSize.getHeadline(context),
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isVerySmallHeight ? 4 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "Building Your Dreams",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: ResponsiveFontSize.getBody(context),
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: headerPadding),
        ],
      ),
    );
  }

  // Login Form Widget (reusable for all layouts) - compact for viewport-fit
  Widget _buildLoginForm(BuildContext context, bool isDark, bool isSmallHeight) {
    final cardPadding = ResponsiveSpacing.getCardPadding(context);
    final headlineSize =
        isSmallHeight ? ResponsiveFontSize.getTitle(context) - 2 : ResponsiveFontSize.getHeadline(context);
    final bodySize = ResponsiveFontSize.getBody(context);
    final titleGap = isSmallHeight ? 2.0 : 8.0;
    final sectionGap = isSmallHeight ? 12.0 : 32.0;
    final cardInnerPadding = isSmallHeight ? cardPadding * 0.8 : cardPadding * 1.5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: isSmallHeight ? 2 : 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            "Welcome Back",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: headlineSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        SizedBox(height: titleGap),
        Text(
          "Sign in to continue managing your projects",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: isSmallHeight ? bodySize - 1 : bodySize,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .color!
                    .withOpacity(0.6),
              ),
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: sectionGap),

        // Form Card
        Container(
          padding: EdgeInsets.all(cardInnerPadding),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LogInForm(
                formKey: _formKey,
                onEmailChanged: (value) => _email = value,
                onPasswordChanged: (value) => _password = value,
                compact: isSmallHeight,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                  child: TextButton(
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveFontSize.getBody(context),
                        color: logoRed,
                      ),
                    ),
                    onPressed: () {
                      if (widget.onForgotPassword != null) {
                        widget.onForgotPassword!();
                      } else {
                        Navigator.pushNamed(context, passwordRecoveryScreenRoute);
                      }
                    },
                  ),
              ),
            ],
          ),
        ),

        SizedBox(height: sectionGap),

        // Login Button
        SizedBox(
          width: double.infinity,
          height: isSmallHeight ? 48 : 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: logoRed,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: logoRed.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                    ),
                  )
                : Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: (isSmallHeight ? ResponsiveFontSize.getBody(context) : ResponsiveFontSize.getBody(context) + 2),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),

        SizedBox(height: isSmallHeight ? 8 : 24),

        // Professional footer
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "© ${DateTime.now().year} Walldot Builders. All rights reserved.",
              style: TextStyle(
                fontSize: (isSmallHeight ? ResponsiveFontSize.getBody(context) - 3 : ResponsiveFontSize.getBody(context) - 2),
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .color!
                    .withOpacity(0.4),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
