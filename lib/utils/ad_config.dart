class AdConfig {
  AdConfig._();

  // AdMob App ID: ca-app-pub-4974791906266394~1619455967
  // Registered in AndroidManifest.xml and ios/Runner/Info.plist

  // Banner ad unit ID — used for bottom banners and inline medium rectangle cards.
  // TODO: switch back to real ID before release: ca-app-pub-4974791906266394/1779797786
  static const String adUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Google test banner ID

  // Native ad unit ID — reserved for future native ad implementation.
  // Requires NativeAdFactory on Android (MainActivity.kt) and iOS (AppDelegate.swift).
  static const String nativeAdUnitId = 'ca-app-pub-4974791906266394/4649503708';
}
