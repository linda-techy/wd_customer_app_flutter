import 'package:flutter/material.dart';
import '../entry_point.dart';
import '../screens/dashboard/views/customer_dashboard_screen.dart';
import '../models/api_models.dart';

import 'screen_export.dart';

// Construction-focused routing for Walldot Builders Customer App
// Removed all e-commerce routes (products, cart, checkout, etc.)

Route<dynamic> generateRoute(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '');
  final path = uri.path;
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  
  // Handle routes with path parameters
  if (segments.isNotEmpty) {
    final basePath = segments[0];
    
    // Project detail routes with ID parameter
    if (segments.length == 2) {
      final projectId = int.tryParse(segments[1]);
      
      switch (basePath) {
        case 'project_details':
          if (projectId != null) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => ProjectDetailsScreen(projectId: projectId),
            );
          }
          break;
        case 'documents':
          if (projectId != null) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => DocumentsScreen(projectId: projectId),
            );
          }
          break;
        case 'floor_plan':
          if (projectId != null) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => FloorPlanScreen(projectId: projectId),
            );
          }
          break;
        case 'three_d_design':
          if (projectId != null) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => ThreeDDesignScreen(projectId: projectId),
            );
          }
          break;
        case 'schedule':
          if (projectId != null) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => ScheduleScreen(projectId: projectId),
            );
          }
          break;
        case 'cctv_surveillance':
          if (projectId != null) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => CctvSurveillanceScreen(projectId: projectId),
            );
          }
          break;
      }
    }
  }
  
  switch (settings.name) {
    // Onboarding & Auth
    case onbordingScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OnbordingScrenn(),
      );
    case logInScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      );
    case passwordRecoveryScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PasswordRecoveryScreen(),
      );

    // Main Navigation
    case entryPointScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EntryPoint(),
      );
    case homeScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );
    case customerDashboardScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const CustomerDashboardScreen(),
      );

    // Search (for projects/documents)
    case searchScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      );

    // Profile & Settings
    case profileScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      );
    case userInfoScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const UserInfoScreen(),
      );
    case preferencesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PreferencesScreen(),
      );

    // Notifications
    case notificationsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      );
    case noNotificationScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NoNotificationScreen(),
      );
    case enableNotificationScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EnableNotificationScreen(),
      );
    case notificationOptionsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const NotificationOptionsScreen(),
      );

    // Addresses (Job Sites)
    case addressesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AddressesScreen(),
      );

    // Projects
    case projectScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProjectScreen(),
      );
    case projectDetailsScreenRoute:
      final project = settings.arguments as ProjectCard?;
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => ProjectDetailsScreen(project: project),
      );
    case floorPlanScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const FloorPlanScreen(),
      );
    case threeDDesignScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const ThreeDDesignScreen(),
      );
    case scheduleScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const ScheduleScreen(),
      );
    case cctvSurveillanceScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const CctvSurveillanceScreen(),
      );
    case documentsScreenRoute:
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => const DocumentsScreen(),
      );

    // Content
    case blogScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const BlogScreen(),
      );
    case portfolioScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PortfolioScreen(),
      );

    // Default/Fallback
    default:
      return MaterialPageRoute(
        builder: (context) => const OnbordingScrenn(),
      );
  }
}
