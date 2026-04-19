import 'package:flutter/material.dart';
import 'inline_ad_card.dart';

/// Returns true if [effectiveIndex] is an ad slot.
/// Ad slots are at effective indices 5, 14, 23, 32, ... (every 9th position starting at 5).
bool isAdIndex(int effectiveIndex) {
  if (effectiveIndex < 5) return false;
  return (effectiveIndex - 5) % 9 == 0;
}

/// Maps an [effectiveIndex] (which includes ad slots) to the real data index.
/// Only call this when [isAdIndex] returns false for [effectiveIndex].
int realIndexFor(int effectiveIndex) {
  final int adsBefore =
      effectiveIndex < 5 ? 0 : ((effectiveIndex - 5) ~/ 9) + 1;
  return effectiveIndex - adsBefore;
}

/// Returns the total item count including ad slots for a list with [realCount] real items.
int effectiveItemCount(int realCount) {
  if (realCount < 5) return realCount;
  return realCount + ((realCount - 5) ~/ 8) + 1;
}

/// Returns the widget for [effectiveIndex]: an [InlineAdCard] for ad slots,
/// or the result of [realBuilder] for real items.
Widget adAwareItemBuilder(
  int effectiveIndex,
  Widget Function(int realIndex) realBuilder,
) {
  if (isAdIndex(effectiveIndex)) return const InlineAdCard();
  return realBuilder(realIndexFor(effectiveIndex));
}
