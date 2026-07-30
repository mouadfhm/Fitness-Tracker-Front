import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

/// Must stay in sync with the `channel_id` the backend sets on its Android
/// payloads (app/Services/NotificationService.php) and with the
/// default_notification_channel_id meta-data in AndroidManifest.xml.
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'fitness_reminders',
  'Reminders & Achievements',
  description: 'Workout reminders, meal reminders and achievement unlocks.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // Android renders `notification` payloads into the tray on its own. This
  // handler only has to exist so the isolate can start for data-only messages.
  await Firebase.initializeApp();
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  await _initLocalNotifications();
}

Future<void> _initLocalNotifications() async {
  await _localNotifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);
}

Future<void> setupFCM(ApiService api) async {
  try {
    await _requestNotificationPermission();

    final messaging = FirebaseMessaging.instance;

    // iOS only: without this, foreground messages are silently suppressed.
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await messaging.getToken();
    if (token != null) {
      await api.registerFcmToken(token);
    } else {
      debugPrint('FCM: getToken() returned null, device not registered');
    }

    messaging.onTokenRefresh.listen((newToken) {
      api.registerFcmToken(newToken);
    });

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  } catch (e) {
    debugPrint('FCM setup failed: $e');
  }
}

void _showForegroundNotification(RemoteMessage message) {
  final notification = message.notification;
  if (notification == null) return;

  // Android drops incoming FCM notifications while the app is in the
  // foreground, so re-post them locally. iOS already presents them via
  // setForegroundNotificationPresentationOptions above, so re-posting there
  // would show the same notification twice.
  if (defaultTargetPlatform != TargetPlatform.android) return;

  _localNotifications.show(
    id: notification.hashCode,
    title: notification.title,
    body: notification.body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );
}

Future<void> _requestNotificationPermission() async {
  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint('FCM permission granted');
  } else {
    debugPrint('FCM permission denied');
  }
}
