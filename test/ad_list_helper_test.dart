import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_app/utils/ad_list_helper.dart';

void main() {
  group('effectiveItemCount', () {
    test('returns real count unchanged when fewer than 5 items', () {
      expect(effectiveItemCount(0), 0);
      expect(effectiveItemCount(4), 4);
    });

    test('adds one ad slot for 5 to 12 real items', () {
      expect(effectiveItemCount(5), 6);
      expect(effectiveItemCount(6), 7);
      expect(effectiveItemCount(12), 13);
    });

    test('adds two ad slots for 13 to 20 real items', () {
      expect(effectiveItemCount(13), 15);
      expect(effectiveItemCount(14), 16);
      expect(effectiveItemCount(20), 22);
    });

    test('adds three ad slots for 21 to 28 real items', () {
      expect(effectiveItemCount(21), 24);
      expect(effectiveItemCount(28), 31);
    });
  });

  group('isAdIndex', () {
    test('returns false for indices 0-4', () {
      for (int i = 0; i < 5; i++) {
        expect(isAdIndex(i), isFalse, reason: 'index $i should not be an ad');
      }
    });

    test('returns true at 5, 14, 23', () {
      expect(isAdIndex(5), isTrue);
      expect(isAdIndex(14), isTrue);
      expect(isAdIndex(23), isTrue);
    });

    test('returns false for non-ad indices', () {
      expect(isAdIndex(4), isFalse);
      expect(isAdIndex(6), isFalse);
      expect(isAdIndex(13), isFalse);
      expect(isAdIndex(15), isFalse);
    });
  });

  group('realIndexFor', () {
    test('maps effective 0-4 to real 0-4 (no ads before)', () {
      for (int i = 0; i < 5; i++) {
        expect(realIndexFor(i), i);
      }
    });

    test('maps effective 6-13 to real 5-12 (one ad before at 5)', () {
      expect(realIndexFor(6), 5);
      expect(realIndexFor(13), 12);
    });

    test('maps effective 15-22 to real 13-20 (two ads before)', () {
      expect(realIndexFor(15), 13);
      expect(realIndexFor(22), 20);
    });
  });
}
