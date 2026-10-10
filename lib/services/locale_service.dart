/// Holds the current language code for [ApiService] to read when building
/// request headers. `ApiService` has no `BuildContext`, so it can't read
/// `Localizations.localeOf(context)` directly — `LocaleProvider` writes here
/// whenever the user's language changes, and this stays in sync from app
/// startup (loaded from prefs before the first widget builds).
class LocaleService {
  static String languageCode = 'en';
}
