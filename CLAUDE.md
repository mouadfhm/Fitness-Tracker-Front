# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (development)
flutter run

# Build for release
flutter build apk           # Android
flutter build ios           # iOS
flutter build windows       # Windows

# Analyze code
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Store builds: push a version tag (git tag v2.0.1 && git push origin v2.0.1).
# .github/workflows/ios-release.yml archives on a GitHub Mac and uploads to App Store
# Connect (TestFlight); .github/workflows/android-release.yml uploads the app bundle to
# Google Play's internal track. Both can also be run from the Actions tab.

# Generate app icons from lib/assets/fitnessTrackerLogo.png
flutter pub run flutter_launcher_icons
```

## Environment Configuration

The app uses `flutter_dotenv` with two env files (both listed as assets in `pubspec.yaml`):
- `.env.development`
- `.env.production`

`main.dart` loads `.env.production` by default. Switch to `.env.development` by changing the `dotenv.load(fileName: ...)` call. Both files must define `BASE_URL` (the backend API base URL). Optional: `SUPPORT_EMAIL` (shown in Help) and `PRIVACY_POLICY_URL` (linked from Register, Settings and Help, opened with `?lang=` set to the app's language; when unset, the links go to the backend's own `/privacy` page, BASE_URL without its trailing `/api`).

## Architecture

### State Management
Uses `provider` package with `ChangeNotifier`. All providers are registered at the root in `main.dart` via `MultiProvider`. Current providers:
- `ProfileProvider` — user profile, BMI calculation, health stats
- `FoodProvider` — food search/management
- `ExercisesProvider` — exercise data
- `AchievementsProvider` — user achievements
- `ThemeProvider` — light/dark theme toggle (persisted via `shared_preferences`)
- `LocaleProvider` — app language (English or French, persisted via `shared_preferences`); a null locale follows the phone's language, which is the default until the user picks one in Settings; strings come from `lib/l10n/*.arb`, regenerated with `flutter gen-l10n`

### Service Layer
All network calls go through `lib/services/api_service.dart`, which reads `BASE_URL` from dotenv and attaches Bearer tokens to authenticated requests. Key services:

- **`ApiService`** — main backend client covering auth, profile, meals, foods, workouts (v1 and v2), progress, goals, achievements
- **`TokenService`** — static wrapper around `FlutterSecureStorage` for JWT token persistence (mobile only; web localStorage code is commented out)
- **`FoodService`** — calls Open Food Facts API (`world.openfoodfacts.org`) for barcode lookups
- **`FirebaseService`** — Firebase Cloud Messaging setup

### API Versioning
There are two API versions in use:
- **v1** (`$baseUrl/...`): auth, profile, goals, meals, progress, achievements, and basic workouts (`/workouts/add`, `/workouts/exercises`, `/workouts/calories-burned`)
- **v2** (`$baseUrl/v2/workouts/...`): custom workouts, scheduled workouts, and weekly cycle plans

### Navigation
Bottom navigation (`lib/screens/widgets/bottom_nav_bar.dart`) connects four top-level screens: Home (Today), Workouts, Foods, Profile (Me). They live in `MainShell` (`lib/screens/main_shell.dart`), an `IndexedStack` that keeps each tab alive so switching back keeps its place; the shell draws the one nav bar for all tabs (so its selection animates between them), and the bar switches tabs through `MainShellScope`. Tab screens don't add a nav bar of their own. The named routes `/home`, `/workouts`, `/foods`, `/profile` open the shell on that tab.

### Theme
Light and dark themes live in `lib/utils/app_theme.dart`: a white page in light mode, and cards styled once through `cardTheme` (white with a thin border and soft shadow in light mode). Use a plain `Card` without its own `color`/`elevation`/`shape` so every page matches; for card-like containers that can't be a `Card`, use `AppTheme.cardDecoration(context)`.

For dialogs, date and time pickers use `AlertDialog.adaptive` with `AdaptiveDialogAction`, `showAdaptiveDatePicker` and `showAdaptiveTimePicker` (`lib/utils/adaptive.dart`) so iPhone users get iOS-style controls.

### Token/Auth Flow
On startup, `main.dart` calls `TokenService.getToken()`. If a token exists, the app starts on `MainShell` (Today tab); otherwise on `LoginScreen`. Logout clears the token via `ApiService.logout()` → `TokenService.deleteToken()` and navigates back to `LoginScreen` with the entire navigation stack cleared.

### Platform Notes
- Token storage uses `FlutterSecureStorage` (mobile/desktop). Web localStorage code exists but is commented out throughout `token_service.dart` and related files.
- Profile pictures are stored locally (file path in `SharedPreferences`), not uploaded to the server yet — the upload call is commented out in `ProfileProvider`.
- Firebase and Google Mobile Ads are initialized but ads integration is commented out.
- iOS minimum is 15.0 (Firebase iOS SDK 12, from firebase_core 4.x). `ios/Podfile` is committed with that platform.

### Assets
- `lib/assets/` — images and `foods.json` (local food database)
- Both `.env.*` files must be present at the project root and declared as assets in `pubspec.yaml`
