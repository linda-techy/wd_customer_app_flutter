import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'route/screen_export.dart';
import 'components/walldot_logo.dart';
import 'screens/dashboard/views/customer_dashboard_screen.dart';
import 'utils/responsive.dart';
import 'services/auth_service.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  List _pages = [];
  int _currentIndex = 0;
  bool _isLoggedIn = false;
  bool _isLoading = true;
  bool _forceHome = false;
  bool _forceProjectDashboard = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read forceHome argument from route (once per mount)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      if (args['forceHome'] == true) {
        _forceHome = true;
      }
      if (args['forceProjectDashboard'] == true) {
        _forceProjectDashboard = true;
      }
    }
    // Refresh auth status when dependencies change (e.g., after sign out)
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
      _updatePages();
      if (_forceHome) {
        _currentIndex = 0; // Ensure Home tab is selected
        _forceHome = false; // consume the flag
      } else if (_forceProjectDashboard) {
        _currentIndex = 4; // Project tab
        _forceProjectDashboard = false;
      }
    });
  }

  void _updatePages() {
    if (_isLoggedIn) {
      // Always keep Home as first tab, even when logged in
      _pages = [
        const HomeScreen(),
        const NotificationsScreen(),
        const BlogScreen(),
        const CustomerDashboardScreen(),
        const PortfolioScreen(),
        const ProfileScreen(),
      ];
    } else {
      // When not logged in, show home screen as first tab
      _pages = [
        const HomeScreen(),
        const NotificationsScreen(),
        const BlogScreen(),
        const ProjectScreen(),
        const PortfolioScreen(),
        const ProfileScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final bool isDesktop = Responsive.isDesktop(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Desktop layout with sidebar
    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar Navigation
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(5, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Logo Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        const WalldotLogo(
                          size: 40,
                          showText: false,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Walldot\nBuilders",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: logoRed,
                                  height: 1.2,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Navigation Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        _buildSidebarItem(
                          context,
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home,
                          label: "Home",
                          index: 0,
                          isDark: isDark,
                        ),

                        _buildSidebarItem(
                          context,
                          icon: Icons.notifications_outlined,
                          activeIcon: Icons.notifications,
                          label: "Notifications",
                          index: 2,
                          isDark: isDark,
                        ),
                        _buildSidebarItem(
                          context,
                          icon: Icons.article_outlined,
                          activeIcon: Icons.article,
                          label: "Blog",
                          index: 3,
                          isDark: isDark,
                        ),
                        _buildSidebarItem(
                          context,
                          icon: Icons.construction_outlined,
                          activeIcon: Icons.construction,
                          label: "Projects",
                          index: 4,
                          isDark: isDark,
                        ),
                        _buildSidebarItem(
                          context,
                          icon: Icons.work_outline,
                          activeIcon: Icons.work,
                          label: "Portfolio",
                          index: 5,
                          isDark: isDark,
                        ),
                        _buildSidebarItem(
                          context,
                          icon: Icons.person_outline,
                          activeIcon: Icons.person,
                          label: "Profile",
                          index: 6,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: blackColor.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        const SizedBox(width: 12),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _currentIndex = 1; // Notifications index
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _currentIndex == 1
                                    ? logoRed
                                    : logoRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _currentIndex == 1
                                    ? Icons.notifications
                                    : Icons.notifications_outlined,
                                color:
                                    _currentIndex == 1 ? Colors.white : logoRed,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content Area
                  Expanded(
                    child: PageTransitionSwitcher(
                      duration: defaultDuration,
                      transitionBuilder: (child, animation, secondAnimation) {
                        return FadeThroughTransition(
                          animation: animation,
                          secondaryAnimation: secondAnimation,
                          child: child,
                        );
                      },
                      child: _pages[_currentIndex],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile/Tablet layout with bottom navigation
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const SizedBox(),
        leadingWidth: 0,
        centerTitle: false,
        title: Row(
          children: [
            const WalldotLogo(
              size: 32,
              showText: false,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                "Walldot Builders",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: logoRed,
                      letterSpacing: 0.5,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [

          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _currentIndex = 1; // Notifications index
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 1 ? logoRed : logoRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _currentIndex == 1
                        ? Icons.notifications
                        : Icons.notifications_outlined,
                    color: _currentIndex == 1 ? Colors.white : logoRed,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageTransitionSwitcher(
        duration: defaultDuration,
        transitionBuilder: (child, animation, secondAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _getBottomNavIndex(),
            onTap: (index) {
              // Map bottom nav index to actual page index
              final pageIndex = _getPageIndexFromBottomNav(index);
              if (pageIndex != _currentIndex) {
                setState(() {
                  _currentIndex = pageIndex;
                });
              }
            },
            backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedItemColor: logoRed,
            unselectedItemColor: blackColor40,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 24),
                activeIcon: Icon(Icons.home, size: 24),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined, size: 24),
                activeIcon: Icon(Icons.article, size: 24),
                label: "Blog",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.construction_outlined, size: 24),
                activeIcon: Icon(Icons.construction, size: 24),
                label: "Project",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.work_outline, size: 24),
                activeIcon: Icon(Icons.work, size: 24),
                label: "Portfolio",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 24),
                activeIcon: Icon(Icons.person, size: 24),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods to map between bottom nav and page indices
  int _getBottomNavIndex() {
    // Map page index to bottom nav index
    // Pages: 0=Home, 1=Notifications, 2=Blog, 3=Project, 4=Portfolio, 5=Profile
    // Bottom Nav: 0=Home, 1=Blog, 2=Project, 3=Portfolio, 4=Profile
    switch (_currentIndex) {
      case 0:
        return 0; // Home
      case 2:
        return 1; // Blog
      case 3:
        return 2; // Project
      case 4:
        return 3; // Portfolio
      case 5:
        return 4; // Profile
      default:
        return 0; // Default to Home if Notifications is active
    }
  }

  int _getPageIndexFromBottomNav(int bottomNavIndex) {
    // Map bottom nav index to page index
    switch (bottomNavIndex) {
      case 0:
        return 0; // Home
      case 1:
        return 2; // Blog
      case 2:
        return 3; // Project
      case 3:
        return 4; // Portfolio
      case 4:
        return 5; // Profile
      default:
        return 0;
    }
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final bool isActive = _currentIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isActive ? logoRed.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (index != _currentIndex) {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 24,
                  color: isActive
                      ? logoRed
                      : (isDark ? Colors.white70 : blackColor60),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? logoRed
                          : (isDark ? Colors.white70 : blackColor),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
