import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/utils/add_banner.dart';
import 'package:fitness_tracker_app/utils/inline_ad_card.dart';

void main() {
  group('AdBannerWidget', () {
    testWidgets('renders SizedBox.shrink when no ad loaded', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AdBannerWidget())),
      );
      // Before ad loads, widget should occupy zero space
      final sizedBox = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.any((b) => b.width == 0 && b.height == 0), isTrue);
    });
  });

  group('InlineAdCard', () {
    testWidgets('renders SizedBox.shrink when no ad loaded', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: InlineAdCard())),
      );
      final sizedBox = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.any((b) => b.width == 0 && b.height == 0), isTrue);
    });
  });
}
