import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';

class InlineAdCard extends StatefulWidget {
  const InlineAdCard({super.key});

  @override
  State<InlineAdCard> createState() => _InlineAdCardState();
}

class _InlineAdCardState extends State<InlineAdCard> {
  BannerAd? _ad;

  @override
  void initState() {
    super.initState();
    if (!Platform.isAndroid && !Platform.isIOS) return;
    _ad = BannerAd(
      adUnitId: AdConfig.adUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _ad = ad as BannerAd),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() => _ad = null);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ad == null) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
