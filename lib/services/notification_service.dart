import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_options.dart';
import '../route/route_constants.dart';
// ignore: directives_ordering
import '../main.dart' show MyApp;

/// Background message handler — must be a top-level function.
/// Called when a push notification arrives while the app is terminated or in the background.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // System tray notification is shown automatically by FCM; no local show needed here.
}

/// Manages Firebase Cloud Messaging for the customer app.
///
/// Usage:
///   1. Register background handler in main() before runApp():
///      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
///
///   2. Call NotificationService.initialize() after the user logs in,
///      passing a callback that POSTs the FCM token to the backend.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  static const String _channelId = 'walldot_channel';
  static const String _channelName = 'Walldot Notifications';

  // Read VAPID key from dart-define environment variable.
  // Build with: --dart-define=FCM_VAPID_KEY=<your_key>
  static const String _vapidKey =
      String.fromEnvironment('FCM_VAPID_KEY', defaultValue: '');

  /// Initialize Firebase, request permissions, register handlers and send the
  /// FCM token to the backend via [onTokenReceived].
  static Future<void> initialize({
    required Future<void> Function(String token) onTokenReceived,
  }) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Request notification permission (iOS + Android 13+)
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // Initialize flutter_local_notifications for foreground display.
    // onDidReceiveNotificationResponse handles taps on locally-shown
    // foreground notifications (payload is the FCM data map toString).
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (details) {
        // Navigate to notifications list — payload parsing not needed here
        // because the FCM data is not easily reconstructed from toString().
        final context = MyApp.navigatorKey.currentContext;
        if (context != null) {
          Navigator.of(context).pushNamed(notificationsScreenRoute);
        }
      },
    );

    // Create Android notification channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.high,
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Get token and register with backend
    final token = await FirebaseMessaging.instance.getToken(vapidKey: _vapidKey);
    if (token != null) await onTokenReceived(token);

    // Refresh token handler
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await onTokenReceived(newToken);
    });

    // Foreground messages — show as local notification
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // Background → foreground tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // Terminated → opened via notification tap
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _handleTap(initial);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;
    await _local.show(
      message.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data.toString(),
    );
  }

  /// Handle a notification tap.
  /// The [message.data] map contains: type, referenceId, projectId.
  static void _handleTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type']?.toString();
    final projectId = data['projectId']?.toString();
    final referenceId = data['referenceId']?.toString();

    final context = MyApp.navigatorKey.currentContext;
    if (context == null) return;

    switch (type) {
      case 'PROJECT_UPDATE':
      case 'PHASE_UPDATED':
        if (projectId != null) {
          Navigator.of(context).pushNamed('project_details/$projectId');
        }
        break;
      case 'PAYMENT_RECORDED':
      case 'INVOICE_ISSUED':
        if (projectId != null) {
          Navigator.of(context).pushNamed(
            paymentsScreenRoute,
            arguments: int.tryParse(projectId),
          );
        }
        break;
      case 'DELAY_REPORTED':
        if (projectId != null) {
          Navigator.of(context).pushNamed('delay_logs/$projectId');
        }
        break;
      case 'TICKET_REPLY':
        if (referenceId != null) {
          Navigator.of(context).pushNamed('ticket_detail/$referenceId');
        }
        break;
      default:
        Navigator.of(context).pushNamed(notificationsScreenRoute);
    }
  }
}
