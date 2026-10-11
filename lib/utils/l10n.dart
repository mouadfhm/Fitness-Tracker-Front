import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import '../services/locale_service.dart';

/// Strings in the app's current language, for code with no [BuildContext]
/// (label helpers, error messages built in services). Widgets should use
/// `AppLocalizations.of(context)!` so they rebuild when the language changes.
AppLocalizations get appL10n =>
    lookupAppLocalizations(Locale(LocaleService.languageCode));
