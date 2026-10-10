import 'dart:io';

import 'package:flutter/foundation.dart';

class AdConfig {
  AdConfig._();

  // AdMob App IDs are per platform and live in the native config:
  //   Android: ca-app-pub-4974791906266394~1619455967 (AndroidManifest.xml)
  //   iOS:     GADApplicationIdentifier in ios/Runner/Info.plist

  // Banner ad unit IDs — used for bottom banners and inline medium rectangle cards.
  static const String _androidAdUnitId = 'ca-app-pub-4974791906266394/1779797786';

  // iOS needs its own AdMob app and ad units: the Android ones don't serve on
  // iOS. Until they exist, ads stay off on iOS. When turning them on, also
  // set GADApplicationIdentifier to the iOS app ID, add SKAdNetworkItems and
  // NSUserTrackingUsageDescription to Info.plist, and show the App Tracking
  // Transparency prompt before requesting personalized ads.
  static const String? _iosAdUnitId = null;

  /// The banner unit for this platform, or null where ads are off.
  static String? get adUnitId {
    if (kIsWeb) return null;
    if (Platform.isAndroid) return _androidAdUnitId;
    if (Platform.isIOS) return _iosAdUnitId;
    return null;
  }

  static bool get enabled => adUnitId != null;

  // Native ad unit ID — reserved for future native ad implementation.
  // Requires NativeAdFactory on Android (MainActivity.kt) and iOS (AppDelegate.swift).
  static const String nativeAdUnitId = 'ca-app-pub-4974791906266394/4649503708';
}
