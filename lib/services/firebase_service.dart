import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

void requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint("User granted permission");
  } else {
    debugPrint("User denied permission");
  }
}
