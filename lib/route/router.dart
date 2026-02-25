import 'package:flutter/material.dart';
import '../entry_point.dart';
import '../screens/dashboard/views/customer_dashboard_screen.dart';
import '../models/api_models.dart';

import 'package:wd_cust_mobile_app/screens/payments/views/payments_screen.dart';
import 'package:wd_cust_mobile_app/screens/project/views/site_updates_screen.dart';
import 'package:wd_cust_mobile_app/screens/project/views/gallery_screen.dart';
import 'package:wd_cust_mobile_app/screens/project/views/snags_screen.dart';
import 'package:wd_cust_mobile_app/screens/project/views/site_visits_screen.dart';
import 'package:wd_cust_mobile_app/screens/project/views/activity_feed_screen.dart';
import 'package:wd_cust_mobile_app/screens/project/views/boq_screen.dart';
import 'package:wd_cust_mobile_app/screens/project/views/quality_check_screen.dart';
import 'package:wd_cust_mobile_app/screens/project/views/view_360_screen.dart';
import 'fade_slide_page_route.dart';
import 'screen_export.dart';
import '../screens/auth/views/reset_password_screen.dart';

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
      final projectIdStr = segments[1];

      switch (basePath) {
        case 'project_details':
          if (projectIdStr.isNotEmpty) {
            return FadeSlidePageRoute(
              settings: settings,
              page: ProjectDetailsScreen(projectId: projectIdStr),
            );
          }
          break;
        case 'documents':
          if (projectIdStr.isNotEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => DocumentsScreen(projectId: projectIdStr),
            );
          }
          break;
        case 'floor_plan':
          if (projectIdStr.isNotEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => FloorPlanScreen(projectId: projectIdStr),
            );
          }
          break;
        case 'three_d_design':
          if (projectIdStr.isNotEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => ThreeDDesignScreen(projectId: projectIdStr),
            );
          }
          break;
        case 'schedule':
          if (projectIdStr.isNotEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => ScheduleScreen(projectId: projectIdStr),
            );
          }
          break;
        case 'cctv_surveillance':
          if (projectIdStr.isNotEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => CctvSurveillanceScreen(projectId: projectIdStr),
            );
          }
          break;
        case 'project_gallery':
          if (projectIdStr.isNotEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => GalleryScreen(projectId: projectIdStr),
            );
          }
          break;
        case 'project_snags':
          if (projectIdStr.isNotEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => SnagsScreen(projectId: projectIdStr),
            );
          }
          break;
        case 'project_site_visits':
          if (projectIdStr.isNotEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => SiteVisitsScreen(projectId: projectIdStr),
            );
          }
          break;
        case 'project_activity_feed':
          if (projectIdStr.isNotEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => ActivityFeedScreen(projectId: projectIdStr),
            );
          }
          break;
        case 'project_boq':
          if (projectIdStr.isNotEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => BoqScreen(projectId: projectIdStr),
            );
          }
          break;
        case 'project_quality_check':
          if (projectIdStr.isNotEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => QualityCheckScreen(projectId: projectIdStr),
            );
          }
          break;
        case 'project_360_views':
          if (projectIdStr.isNotEmpty) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => View360Screen(projectId: projectIdStr),
            );
          }
          break;
        case 'site_updates':
          if (projectIdStr.isNotEmpty) {
            return FadeSlidePageRoute(
              settings: settings,
              page: SiteUpdatesScreen(projectId: projectIdStr),
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
    case passwordRecoveryScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PasswordRecoveryScreen(),
      );
    case resetPasswordScreenRoute:
      final args = settings.arguments as Map<String, String>?;
      final token = args?['token'] ?? '';
      final email = args?['email'] ?? '';
      return MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(token: token, email: email),
      );

    // Main Navigation
    case entryPointScreenRoute:
      return FadeSlidePageRoute(
        page: const EntryPoint(),
      );
    case homeScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );
    case customerDashboardScreenRoute:
      return FadeSlidePageRoute(
        page: const CustomerDashboardScreen(),
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

    // Projects
    case projectScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProjectScreen(),
      );
    case projectsListScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProjectsListScreen(),
      );
    case projectDetailsScreenRoute:
      final project = settings.arguments as ProjectCard?;
      if (project != null) {
        return FadeSlidePageRoute(
          settings: settings,
          page: ProjectDetailsScreen(
            projectId: project.projectUuid ?? project.projectUuid.toString(),
          ),
        );
      }
      return MaterialPageRoute(
        builder: (context) => const ProjectScreen(),
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

    case paymentsScreenRoute:
      final projectId = settings.arguments as int?;
      return FadeSlidePageRoute(
        page: PaymentsScreen(projectId: projectId),
      );
    case siteUpdatesScreenRoute:
      // Check if projectId is provided in route arguments or query params
      final projectId = settings.arguments as String? ?? 
                       uri.queryParameters['projectId'];
      if (projectId != null && projectId.isNotEmpty) {
        return FadeSlidePageRoute(
          page: SiteUpdatesScreen(projectId: projectId),
        );
      }
      // Fallback: try to get projectId from route path if it's in format site_updates/projectId
      if (segments.length == 2 && segments[0] == 'site_updates') {
        return FadeSlidePageRoute(
          page: SiteUpdatesScreen(projectId: segments[1]),
        );
      }
      // If no projectId, show error or redirect
      return FadeSlidePageRoute(
        page: Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(
            child: Text('Project ID is required to view site updates'),
          ),
        ),
      );

    default:
      return MaterialPageRoute(
        builder: (context) => const OnbordingScrenn(),
      );
  }
}
