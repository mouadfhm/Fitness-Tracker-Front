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

# Generate app icons from lib/assets/fitnessTrackerLogo.png
flutter pub run flutter_launcher_icons
```

## Environment Configuration

The app uses `flutter_dotenv` with two env files (both listed as assets in `pubspec.yaml`):
- `.env.development`
- `.env.production`

`main.dart` loads `.env.production` by default. Switch to `.env.development` by changing the `dotenv.load(fileName: ...)` call. Both files must define `BASE_URL` (the backend API base URL).

## Architecture

### State Management
Uses `provider` package with `ChangeNotifier`. All providers are registered at the root in `main.dart` via `MultiProvider`. Current providers:
- `ProfileProvider` — user profile, BMI calculation, health stats
- `FoodProvider` — food search/management
- `ExercisesProvider` — exercise data
- `AchievementsProvider` — user achievements
- `ThemeProvider` — light/dark theme toggle (persisted via `shared_preferences`)

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
Bottom navigation (`lib/screens/widgets/bottom_nav_bar.dart`) connects four top-level screens: Home (Nutrition Tracker), Workout Calendar, Foods, Profile. Navigation uses `Navigator.pushReplacement` between these tabs to avoid stacking them.

### Token/Auth Flow
On startup, `main.dart` calls `TokenService.getToken()`. If a token exists, the app starts on `HomeScreen`; otherwise on `LoginScreen`. Logout clears the token via `ApiService.logout()` → `TokenService.deleteToken()` and navigates back to `LoginScreen` with the entire navigation stack cleared.

### Platform Notes
- Token storage uses `FlutterSecureStorage` (mobile/desktop). Web localStorage code exists but is commented out throughout `token_service.dart` and related files.
- Profile pictures are stored locally (file path in `SharedPreferences`), not uploaded to the server yet — the upload call is commented out in `ProfileProvider`.
- Firebase and Google Mobile Ads are initialized but ads integration is commented out.

### Assets
- `lib/assets/` — images and `foods.json` (local food database)
- Both `.env.*` files must be present at the project root and declared as assets in `pubspec.yaml`
