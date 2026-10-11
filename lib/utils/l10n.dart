import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import '../services/locale_service.dart';

/// Strings in the app's current language, for code with no [BuildContext]
/// (label helpers, error messages built in services). Widgets should use
/// `AppLocalizations.of(context)!` so they rebuild when the language changes.
AppLocalizations get appL10n =>
    lookupAppLocalizations(Locale(LocaleService.languageCode));

/// The name of a food, activity, exercise or achievement from the API in the
/// app's language. The backend adds `display_name` (and, for achievements,
/// `display_description`) in the language of the request; older responses
/// and user-created items only have `name`.
String localizedName(Map item, {String field = 'name', String fallback = ''}) {
  final display = item['display_$field'];
  if (display is String && display.isNotEmpty) return display;
  return item[field]?.toString() ?? fallback;
}
