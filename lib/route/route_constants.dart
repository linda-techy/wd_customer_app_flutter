// Authentication Routes
const String onbordingScreenRoute = "onbording";
const String notificationPermissionScreenRoute = "notification_permission";
const String preferredLanuageScreenRoute = "preferred_language";
const String logInScreenRoute = "login";
const String signUpScreenRoute = "signup";
const String profileSetupScreenRoute = "profile_setup";
const String signUpVerificationScreenRoute = "signup_verification";
const String passwordRecoveryScreenRoute = "password_recovery";
const String verificationMethodScreenRoute = "verification_method";
const String otpScreenRoute = "otp";
const String newPasswordScreenRoute = "new_password";
const String doneResetPasswordScreenRoute = "done_reset_password";
const String termsOfServicesScreenRoute = "terms_of_services";
const String setupFingerprintScreenRoute = "setup_fingerprint";
const String setupFaceIdScreenRoute = "setup_faceid";

// Error & Status Routes
const String noInternetScreenRoute = "no_internet";
const String serverErrorScreenRoute = "server_error";

// Main Navigation Routes
const String homeScreenRoute = "home";
const String entryPointScreenRoute = "entry_point";


// Profile & Settings Routes
const String profileScreenRoute = "profile";
const String userInfoScreenRoute = "user_info";
const String currentPasswordScreenRoute = "current_passowrd";
const String editUserInfoScreenRoute = "edit_user_info";
const String preferencesScreenRoute = "preferences";
const String getHelpScreenRoute = "get_help";
const String chatScreenRoute = "chat";

// Notification Routes
const String notificationsScreenRoute = "notifications";
const String noNotificationScreenRoute = "no_notifications";
const String enableNotificationScreenRoute = "enable_notifications";
const String notificationOptionsScreenRoute = "notification_options";

// Location & Address Routes (for job sites)
const String selectLanguageScreenRoute = "select_language";
const String noAddressScreenRoute = "no_address";
const String addressesScreenRoute = "addresses";
const String addNewAddressesScreenRoute = "add_new_addresses";

// Project Routes
const String projectScreenRoute = "project";
const String projectsListScreenRoute = "projects_list";
const String projectDetailsScreenRoute = "project_details";
const String paymentsScreenRoute = "payments";
const String siteUpdatesScreenRoute = "site_updates";
const String floorPlanScreenRoute = "floor_plan";
const String threeDDesignScreenRoute = "three_d_design";
const String scheduleScreenRoute = "schedule";
const String cctvSurveillanceScreenRoute = "cctv_surveillance";
const String documentsScreenRoute = "documents";
const String projectTimelineScreenRoute = "project_timeline";
const String projectMilestonesScreenRoute = "project_milestones";
const String projectGalleryScreenRoute = "project_gallery";

// New Module Routes
const String projectSnagsScreenRoute = "project_snags";
const String projectSiteVisitsScreenRoute = "project_site_visits";
const String projectActivityFeedScreenRoute = "project_activity_feed";
const String projectBoqScreenRoute = "project_boq";
const String projectQualityCheckScreenRoute = "project_quality_check";
const String project360ViewsScreenRoute = "project_360_views";

// Helper function to build project detail route with ID
String projectDetailsRoute(dynamic projectId) => 'project_details/$projectId';
String projectDocumentsRoute(dynamic projectId) => 'documents/$projectId';
String projectFloorPlanRoute(dynamic projectId) => 'floor_plan/$projectId';
String project3DDesignRoute(dynamic projectId) => 'three_d_design/$projectId';
String projectScheduleRoute(dynamic projectId) => 'schedule/$projectId';
String projectCctvRoute(dynamic projectId) => 'cctv_surveillance/$projectId';
String projectGalleryRoute(dynamic projectId) => 'project_gallery/$projectId';
String projectActivityRoute(dynamic projectId) => 'project_activity/$projectId';
String projectSnagsRoute(dynamic projectId) => 'project_snags/$projectId';
String projectSiteVisitsRoute(dynamic projectId) => 'project_site_visits/$projectId';
String projectActivityFeedRoute(dynamic projectId) => 'project_activity_feed/$projectId';
String projectBoqRoute(dynamic projectId) => 'project_boq/$projectId';
String projectQualityCheckRoute(dynamic projectId) => 'project_quality_check/$projectId';
String project360ViewsRoute(dynamic projectId) => 'project_360_views/$projectId';

// Dashboard Routes
const String customerDashboardScreenRoute = "customer_dashboard";

// Content Routes
const String blogScreenRoute = "blog";
const String blogDetailsScreenRoute = "blog_details";
const String portfolioScreenRoute = "portfolio";
const String portfolioDetailsScreenRoute = "portfolio_details";

// Service Routes
const String servicesScreenRoute = "services";
const String serviceDetailsScreenRoute = "service_details";
const String requestQuoteScreenRoute = "request_quote";
const String scheduleVisitScreenRoute = "schedule_visit";

// Payment & Billing Routes (Construction-focused)
const String billingScreenRoute = "billing";
const String invoicesScreenRoute = "invoices";
const String invoiceDetailsScreenRoute = "invoice_details";
const String paymentHistoryScreenRoute = "payment_history";
const String paymentMethodScreenRoute = "payment_method";

// Communication Routes
const String contactSupportScreenRoute = "contact_support";
const String submitTicketScreenRoute = "submit_ticket";
const String ticketsScreenRoute = "tickets";
