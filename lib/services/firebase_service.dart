import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_options.dart';
import 'api_service.dart';
import 'navigation_service.dart';

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

/// Set by [setupFCM] so the tap handlers can report opens. Null until the user
/// is signed in, which is also when there is no token to authenticate with.
ApiService? _api;

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // Android renders `notification` payloads into the tray on its own. This
  // handler only has to exist so the isolate can start for data-only messages.
  await Firebase.initializeApp(options: _firebaseOptionsForPlatform());
}

/// Native config files (google-services.json / GoogleService-Info.plist)
/// cover Android/iOS implicitly, so only platforms configured via
/// `firebase_options.dart` (currently just Windows) need explicit options.
FirebaseOptions? _firebaseOptionsForPlatform() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    return DefaultFirebaseOptions.windows;
  }
  return null;
}

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: _firebaseOptionsForPlatform());
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  try {
    await _initLocalNotifications();
  } catch (e) {
    debugPrint('Local notifications setup failed: $e');
  }
}

Future<void> _initLocalNotifications() async {
  await _localNotifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: _onLocalNotificationTapped,
  );

  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);
}

Future<void> setupFCM(ApiService api) async {
  _api = api;

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

    // Tapped while the app was backgrounded.
    FirebaseMessaging.onMessageOpenedApp.listen(_onRemoteNotificationTapped);

    // Tapped while the app was terminated: the notification that launched the
    // process is only ever available here, not from the stream above.
    final launchMessage = await messaging.getInitialMessage();
    if (launchMessage != null) {
      _onRemoteNotificationTapped(launchMessage);
    }
  } catch (e) {
    debugPrint('FCM setup failed: $e');
  }
}

void _onRemoteNotificationTapped(RemoteMessage message) {
  _onNotificationTapped(
    message.data['log_id']?.toString(),
    message.data['route']?.toString(),
  );
}

void _onLocalNotificationTapped(NotificationResponse response) {
  // Foreground Android notifications are re-posted locally (see
  // _showForegroundNotification), so their taps arrive here instead. The
  // RemoteMessage is not available in this callback, which is why the data
  // block travels on the payload.
  final data = _decodePayload(response.payload);
  _onNotificationTapped(
    data['log_id']?.toString(),
    data['route']?.toString(),
  );
}

void _onNotificationTapped(String? logId, String? route) {
  _reportOpen(logId);
  _openRoute(route);
}

/// The local plugin carries a single string, so [_showForegroundNotification]
/// packs the data block into it as JSON.
Map<String, dynamic> _decodePayload(String? payload) {
  if (payload == null || payload.isEmpty) return const {};

  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map<String, dynamic>) return decoded;
  } catch (e) {
    debugPrint('FCM: unreadable notification payload: $e');
  }
  return const {};
}

/// Opens the screen the notification is about. A null target means the
/// notification names no particular screen, so the app opens where it was —
/// on a cold start that is the home screen already.
void _openRoute(String? route) {
  final target = NavigationService.deepLinkTarget(route);
  if (target == null) return;

  // On a cold start the launching message is handled before the first frame,
  // when navigatorKey has no state yet and the navigation would be silently
  // dropped. Deferring costs nothing in the other two cases.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Cleared down to the target so the back button behaves the same as it
    // does on the bottom-nav tabs, which are all roots.
    NavigationService.navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(target, (_) => false);
  });
}

/// [logId] is the `notification_logs` row id the backend puts in the FCM data
/// block. Fire-and-forget: reporting an open must never delay or block the UI,
/// and markNotificationOpened swallows its own errors.
void _reportOpen(String? logId) {
  if (logId == null || logId.isEmpty) return;

  final api = _api;
  if (api == null) return;

  unawaited(api.markNotificationOpened(logId));
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
    // Carried through so the tap can be reported against the same log row the
    // backend created for this send, and land on the screen it is about.
    payload: jsonEncode({
      'log_id': message.data['log_id']?.toString(),
      'route': message.data['route']?.toString(),
    }),
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
