import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// iOS-style controls on iPhone, Material ones elsewhere, for the few places
/// Flutter has no `.adaptive` constructor of its own.

bool _isCupertino(BuildContext context) {
  final platform = Theme.of(context).platform;
  return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
}

/// A button for [AlertDialog.adaptive]'s actions: a [CupertinoDialogAction]
/// on iOS (red when [isDestructive], bold when [isDefault]), a [TextButton]
/// with [style] elsewhere.
class AdaptiveDialogAction extends StatelessWidget {
  const AdaptiveDialogAction({
    super.key,
    required this.onPressed,
    required this.child,
    this.isDestructive = false,
    this.isDefault = false,
    this.style,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isDestructive;
  final bool isDefault;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    if (_isCupertino(context)) {
      return CupertinoDialogAction(
        onPressed: onPressed,
        isDestructiveAction: isDestructive,
        isDefaultAction: isDefault,
        child: child,
      );
    }
    return TextButton(onPressed: onPressed, style: style, child: child);
  }
}

/// [showDatePicker] on Android; on iOS a wheel picker in a bottom sheet with
/// Cancel and Done, which is what iPhone users expect for picking a date.
/// [builder] only applies to the Material picker.
Future<DateTime?> showAdaptiveDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  TransitionBuilder? builder,
}) {
  if (!_isCupertino(context)) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: builder,
    );
  }
  DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  final first = dateOnly(firstDate);
  final last = dateOnly(lastDate);
  var initial = dateOnly(initialDate);
  if (initial.isBefore(first)) initial = first;
  if (initial.isAfter(last)) initial = last;
  return _showCupertinoPickerSheet<DateTime>(
    context: context,
    initialValue: initial,
    picker: (onChanged) => CupertinoDatePicker(
      mode: CupertinoDatePickerMode.date,
      initialDateTime: initial,
      minimumDate: first,
      maximumDate: last,
      onDateTimeChanged: onChanged,
    ),
  );
}

/// [showTimePicker] on Android; a wheel time picker on iOS.
Future<TimeOfDay?> showAdaptiveTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  if (!_isCupertino(context)) {
    return showTimePicker(context: context, initialTime: initialTime);
  }
  final now = DateTime.now();
  final initial = DateTime(now.year, now.month, now.day, initialTime.hour, initialTime.minute);
  final picked = await _showCupertinoPickerSheet<DateTime>(
    context: context,
    initialValue: initial,
    picker: (onChanged) => CupertinoDatePicker(
      mode: CupertinoDatePickerMode.time,
      initialDateTime: initial,
      use24hFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      onDateTimeChanged: onChanged,
    ),
  );
  return picked == null ? null : TimeOfDay.fromDateTime(picked);
}

Future<T?> _showCupertinoPickerSheet<T>({
  required BuildContext context,
  required T initialValue,
  required Widget Function(ValueChanged<T> onChanged) picker,
}) {
  var value = initialValue;
  return showCupertinoModalPopup<T>(
    context: context,
    builder: (context) => Container(
      height: 300,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(value),
                  child: Text(AppLocalizations.of(context)!.adaptiveDone, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            Expanded(child: picker((v) => value = v)),
          ],
        ),
      ),
    ),
  );
}
