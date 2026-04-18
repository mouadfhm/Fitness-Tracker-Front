// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:flutter/material.dart';

// class AdBanner extends StatefulWidget {
//   const AdBanner({super.key});

//   @override
//   State<AdBanner> createState() => _AdBannerState();
// }

// class _AdBannerState extends State<AdBanner> {
//   BannerAd? _bannerAd;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _bannerAd = BannerAd(
//       adUnitId: 'ca-app-pub-4974791906266394/1515332348', // Replace with your Ad Unit ID
//       size: AdSize.banner,
//       request: AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           setState(() {
//             _bannerAd = ad as BannerAd;
//           });
//         },
//         onAdFailedToLoad: (ad, err) {
//           print('Failed to load a banner ad: ${err.message}');
//           setState(() {
//             _bannerAd = null;
//           });
//         },
//       ),
//     )..load();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       width: _bannerAd?.size.width.toDouble(),
//       height: _bannerAd?.size.height.toDouble(),
//       child: _bannerAd == null ? const SizedBox.shrink() : AdWidget(ad: _bannerAd!),
//     );
//   }
// }

