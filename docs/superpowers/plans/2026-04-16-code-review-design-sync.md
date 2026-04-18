# Code Review, Optimization & Design Sync — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Unify the app under a teal Material 3 theme, fix 6 bugs, eliminate code duplication, and apply a consistent card/AppBar standard across all screens.

**Architecture:** A shared `AppTextField` widget and updated `CustomBottomNavBar` (using named routes — no `onTap` param) eliminate the two largest duplication sources. All color tokens flow from a single `ColorScheme.fromSeed(seedColor: Colors.teal)` in `main.dart`; no screen hard-codes a color.

**Tech Stack:** Flutter 3.x, Dart 3.x, Material 3, `provider` ^6.1.1

---

## File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `lib/screens/widgets/app_text_field.dart` | Shared themed text field used by Login and Register |
| Modify | `lib/main.dart` | Teal seed, scaffold background, named routes |
| Modify | `lib/screens/widgets/bottom_nav_bar.dart` | Theme colors, internal navigation via named routes, remove `onTap` param |
| Modify | `lib/screens/login_screen.dart` | Theme-aware, `mounted` checks, use `AppTextField` |
| Modify | `lib/screens/register_screen.dart` | Theme-aware, `mounted` checks, use `AppTextField` |
| Modify | `lib/screens/home_screen.dart` | Fix logout pop bug, card/AppBar standards, remove `_onNavBarTap` |
| Modify | `lib/screens/profile_screen.dart` | Fix logout nav stack, remove dead code, card/AppBar standards, remove `_onNavBarTap` |
| Modify | `lib/screens/foods_screen.dart` | Fix scanned food stale state, `mounted` guard, remove `debugPrint`, remove `_onNavBarTap` |
| Modify | `lib/screens/workout/workout_calendar_screen.dart` | Replace custom color system with `colorScheme`, fix `_filteredWorkouts` leak, remove `debugPrint`, remove `_onNavBarTap` |
| Modify | `lib/screens/settings_screen.dart` | Fix dead variable, AppBar standard |
| Rename | `lib/utils/addBanner.dart` → `lib/utils/add_banner.dart` | Dart filename convention |

---

## Task 1: Teal Theme System in `main.dart`

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Replace ThemeData blocks with teal seed + scaffold background + named routes**

Replace the two `ThemeData` blocks and add `routes:` inside `MaterialApp` in `lib/main.dart`:

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/food_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/achievement_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/foods_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/workout/workout_calendar_screen.dart';
import 'services/token_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env.production");
  final token = await TokenService.getToken();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()..fetchProfile()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => ExercisesProvider()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(isLoggedIn: token != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Fitness Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFE0F2F1),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeProvider.themeMode,
      routes: {
        '/home': (_) => const HomeScreen(),
        '/workouts': (_) => const WorkoutCalendarScreen(),
        '/foods': (_) => const FoodsScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
```

- [ ] **Step 2: Verify no static analysis errors**

```bash
flutter analyze
```

Expected: no errors (only existing warnings, if any).

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: seed teal theme with scaffold tint and named routes"
```

---

## Task 2: Shared `AppTextField` Widget

**Files:**
- Create: `lib/screens/widgets/app_text_field.dart`

- [ ] **Step 1: Create the file**

```dart
// lib/screens/widgets/app_text_field.dart
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool? showObscureToggle;
  final VoidCallback? onObscureToggle;

  const AppTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.showObscureToggle,
    this.onObscureToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: colorScheme.onSurface),
      cursorColor: colorScheme.primary,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        suffixIcon: showObscureToggle != null
            ? IconButton(
                icon: Icon(
                  showObscureToggle! ? Icons.visibility_off : Icons.visibility,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: onObscureToggle,
              )
            : null,
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) return 'Please enter $labelText';
            return null;
          },
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/widgets/app_text_field.dart
git commit -m "feat: add shared AppTextField widget with theme-aware colors"
```

---

## Task 3: Update `CustomBottomNavBar` — Theme Colors + Internal Navigation

**Files:**
- Modify: `lib/screens/widgets/bottom_nav_bar.dart`

- [ ] **Step 1: Replace file content**

The widget now owns navigation via named routes (registered in Task 1). The `onTap` parameter is removed — screens only pass `currentIndex`.

```dart
// lib/screens/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  static const _routes = ['/home', '/workouts', '/foods', '/profile'];
  static const _icons = [
    Icons.home,
    Icons.fitness_center,
    Icons.restaurant,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BottomAppBar(
      color: colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (i) {
          final isSelected = i == currentIndex;
          return IconButton(
            icon: Icon(
              _icons[i],
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            onPressed: isSelected
                ? null
                : () => Navigator.of(context).pushReplacementNamed(_routes[i]),
          );
        }),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze
```

Expected: errors about `onTap` being passed from screens — those are fixed in subsequent tasks. If running analyze at this point it will show errors. That is expected and will resolve by Task 8. Alternatively, check only this file:

```bash
flutter analyze lib/screens/widgets/bottom_nav_bar.dart
```

Expected: no errors in this file itself.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/widgets/bottom_nav_bar.dart
git commit -m "refactor: bottom nav uses theme colors and named-route navigation"
```

---

## Task 4: Login Screen — Theme-Aware + `mounted` Fixes

**Files:**
- Modify: `lib/screens/login_screen.dart`

- [ ] **Step 1: Replace file content**

Removes `// ignore_for_file` comment, adds `mounted` guards, uses `colorScheme` throughout, uses `AppTextField`.

```dart
// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  void _goToRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await _apiService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Hello Again!',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.primary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Login to continue your fitness journey',
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegex.hasMatch(value)) return 'Please enter a valid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    obscureText: _obscurePassword,
                    showObscureToggle: _obscurePassword,
                    onObscureToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your password';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: colorScheme.onPrimary)
                        : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      GestureDetector(
                        onTap: _goToRegister,
                        child: Text('Register', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/screens/login_screen.dart
```

Expected: no errors or warnings in this file.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/login_screen.dart
git commit -m "fix: login screen theme-aware, mounted guards, use AppTextField"
```

---

## Task 5: Register Screen — Theme-Aware + `mounted` Fixes

**Files:**
- Modify: `lib/screens/register_screen.dart`

- [ ] **Step 1: Replace file content**

```dart
// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'update_profile_screen.dart';
import 'widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await _apiService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _confirmPasswordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const UpdateProfileScreen(
            profileData: {
              'age': 0,
              'weight': 0,
              'height': 0,
              'gender': 'male',
              'activity_level': 'Moderate',
              'fitness_goal': 'weight_loss',
            },
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome!',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.primary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create your account to get started',
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your full name';
                      if (value.length < 2) return 'Name must be at least 2 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegex.hasMatch(value)) return 'Please enter a valid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    obscureText: _obscurePassword,
                    showObscureToggle: _obscurePassword,
                    onObscureToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter a password';
                      if (value.length < 8) return 'Password must be at least 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    obscureText: _obscureConfirmPassword,
                    showObscureToggle: _obscureConfirmPassword,
                    onObscureToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please confirm your password';
                      if (value != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: colorScheme.onPrimary)
                        : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text('Login', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

```bash
flutter analyze lib/screens/register_screen.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/register_screen.dart
git commit -m "fix: register screen theme-aware, mounted guards, use AppTextField"
```

---

## Task 6: Home Screen — Fix Logout Bug + Card/AppBar Standards

**Files:**
- Modify: `lib/screens/home_screen.dart`

- [ ] **Step 1: Remove erroneous `Navigator.of(context).pop()` in logout button**

Find this block (around line 552):
```dart
actions: [
  IconButton(
    icon: const Icon(Icons.logout),
    onPressed: () {
      Navigator.of(context).pop();        // ← DELETE THIS LINE
      _showLogoutConfirmation();
    },
  ),
],
```

Change to:
```dart
actions: [
  IconButton(
    icon: const Icon(Icons.logout),
    onPressed: _showLogoutConfirmation,
  ),
],
```

- [ ] **Step 2: Remove `_onNavBarTap` method and update `CustomBottomNavBar` usage**

Delete the entire `_onNavBarTap` method:
```dart
// DELETE this entire method:
void _onNavBarTap(int index) {
  if (index == _currentIndex) return;
  final routes = [ ... ];
  Navigator.of(context).pushReplacement(...);
}
```

Change the `CustomBottomNavBar` call at the bottom of `build()`:
```dart
// FROM:
bottomNavigationBar: CustomBottomNavBar(
  currentIndex: _currentIndex,
  onTap: _onNavBarTap,
),

// TO:
bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex),
```

- [ ] **Step 3: Apply AppBar standard — change `elevation: 2` to `elevation: 0`**

In the `AppBar`:
```dart
// FROM:
elevation: 2,

// TO:
elevation: 0,
```

- [ ] **Step 4: Apply card standard to `_buildMacroCard`**

Find `_buildMacroCard` and replace the `Card` widget:
```dart
// FROM:
return Card(
  elevation: 4,
  color: cardColor,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: colorScheme.brightness == Brightness.dark
          ? colorScheme.onSurface.withOpacity(0.1)
          : Colors.transparent,
      width: 1,
    ),
  ),
  ...
);

// TO:
return Card(
  elevation: 2,
  color: cardColor,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    side: BorderSide(
      color: colorScheme.primary.withOpacity(0.15),
      width: 1,
    ),
  ),
  ...
);
```

- [ ] **Step 5: Apply card standard to meals section cards in `_buildMealsSection`**

Find the meals `Card` in `ListView.builder` and apply the same standard:
```dart
// FROM:
return Card(
  elevation: 4,
  color: cardColor,
  margin: const EdgeInsets.symmetric(vertical: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: colorScheme.brightness == Brightness.dark
          ? colorScheme.onSurface.withOpacity(0.1)
          : Colors.transparent,
      width: 1,
    ),
  ),
  ...
);

// TO:
return Card(
  elevation: 2,
  color: cardColor,
  margin: const EdgeInsets.symmetric(vertical: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    side: BorderSide(
      color: colorScheme.primary.withOpacity(0.15),
      width: 1,
    ),
  ),
  ...
);
```

- [ ] **Step 6: Remove unused imports no longer needed after removing `_onNavBarTap`**

Check and remove any of these if no longer directly used in `home_screen.dart`:
```dart
// Only remove if unused — check before deleting:
import 'profile_screen.dart';
import 'workout/workout_calendar_screen.dart';
import 'foods_screen.dart';
```

- [ ] **Step 7: Verify**

```bash
flutter analyze lib/screens/home_screen.dart
```

Expected: no errors.

- [ ] **Step 8: Commit**

```bash
git add lib/screens/home_screen.dart
git commit -m "fix: home screen logout pop bug, card/AppBar standards, remove onNavBarTap"
```

---

## Task 7: Profile Screen — Fix Logout Nav Stack + Remove Dead Code

**Files:**
- Modify: `lib/screens/profile_screen.dart`

- [ ] **Step 1: Fix `_logout()` to clear the full navigation stack**

Find:
```dart
void _logout() async {
  await _apiService.logout();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
}
```

Replace with:
```dart
void _logout() async {
  await _apiService.logout();
  if (!mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}
```

- [ ] **Step 2: Remove `_loadSettings()` and its call in `initState`**

In `initState`, delete the call:
```dart
// FROM:
WidgetsBinding.instance.addPostFrameCallback((_) {
  Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
  _loadSettings();   // ← DELETE THIS LINE
});

// TO:
WidgetsBinding.instance.addPostFrameCallback((_) {
  Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
});
```

Delete the entire `_loadSettings` method:
```dart
// DELETE:
Future<void> _loadSettings() async {
  setState(() {});
}
```

- [ ] **Step 3: Remove `_launchPrivacyPolicy()` method and its quick-action button**

Delete the method:
```dart
// DELETE:
void _launchPrivacyPolicy() async {
  // const url = 'https://yourapp.com/privacy-policy';
  // ...
}
```

In the `GridView.count` children list inside `_buildProfileContent`, remove the Privacy button entry:
```dart
// DELETE this entry from the GridView children:
_buildQuickActionButton(
  Icons.privacy_tip_outlined,
  'Privacy',
  _launchPrivacyPolicy,
),
```

- [ ] **Step 4: Remove `_onNavBarTap` and update `CustomBottomNavBar` call**

Delete the entire `_onNavBarTap` method. Update the widget call:
```dart
// FROM:
bottomNavigationBar: CustomBottomNavBar(
  currentIndex: _currentIndex,
  onTap: _onNavBarTap,
),

// TO:
bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex),
```

- [ ] **Step 5: Apply AppBar standard**

In `build()`, find the `AppBar` and ensure:
```dart
AppBar(
  title: Text(
    'Profile',
    style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
  ),
  elevation: 0,
  backgroundColor: colorScheme.surface,
  actions: [ ... ],
),
```

- [ ] **Step 6: Apply card standard to the profile info card**

Find the `Card` wrapping the `_buildProfileTile` list:
```dart
// FROM:
Card(
  elevation: 3,
  color: colorScheme.surface,
  shadowColor: isDarkMode ? Colors.black : Colors.grey[300],
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: isDarkMode ? colorScheme.onSurface.withOpacity(0.1) : Colors.transparent,
      width: 1,
    ),
  ),
  ...
)

// TO:
Card(
  elevation: 2,
  color: colorScheme.surface,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    side: BorderSide(
      color: colorScheme.primary.withOpacity(0.15),
      width: 1,
    ),
  ),
  ...
)
```

- [ ] **Step 7: Remove unused imports after dead code removal**

Remove any imports only used by the deleted methods (e.g., `home_screen.dart`, `workout_calendar_screen.dart`, `foods_screen.dart` if only used by `_onNavBarTap`).

- [ ] **Step 8: Verify**

```bash
flutter analyze lib/screens/profile_screen.dart
```

Expected: no errors.

- [ ] **Step 9: Commit**

```bash
git add lib/screens/profile_screen.dart
git commit -m "fix: profile logout clears nav stack, remove dead code, card/AppBar standards"
```

---

## Task 8: Foods Screen — Fix Stale Scan, `mounted` Guard, Remove `debugPrint`

**Files:**
- Modify: `lib/screens/foods_screen.dart`

- [ ] **Step 1: Clear `_scannedFood` after returning from `FoodDetailsScreen`**

Find the `Navigator.push` to `FoodDetailsScreen` in the barcode scan path (inside `_scanBarcode`):
```dart
// FROM:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => FoodDetailsScreen(food: scannedFood),
  ),
);

// TO:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => FoodDetailsScreen(food: scannedFood),
  ),
).then((_) {
  if (mounted) setState(() => _scannedFood = null);
});
```

- [ ] **Step 2: Add `mounted` guard in `_goToNewFood`**

Find:
```dart
Future<void> _goToNewFood(BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const NewFoodScreen()),
  );
  Provider.of<FoodProvider>(context, listen: false).refreshFoods();
}
```

Replace with:
```dart
Future<void> _goToNewFood(BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const NewFoodScreen()),
  );
  if (!mounted) return;
  Provider.of<FoodProvider>(context, listen: false).refreshFoods();
}
```

- [ ] **Step 3: Remove `debugPrint` from barcode scan**

Find and delete:
```dart
debugPrint('fooooooood: $scannedFood');
```

- [ ] **Step 4: Remove `_onNavBarTap` and update `CustomBottomNavBar` call**

Delete the entire `_onNavBarTap` method. Update:
```dart
// FROM:
bottomNavigationBar: CustomBottomNavBar(
  currentIndex: _currentIndex,
  onTap: _onNavBarTap,
),

// TO:
bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex),
```

- [ ] **Step 5: Apply card standard to food list cards**

Find the `Card` inside `ListView.builder`:
```dart
// FROM:
Card(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  elevation: 3,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ...
)

// TO:
Card(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    side: BorderSide(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
      width: 1,
    ),
  ),
  ...
)
```

- [ ] **Step 6: Remove unused imports (screen imports only used by `_onNavBarTap`)**

Remove any of these if no longer used:
```dart
import 'home_screen.dart';
import 'profile_screen.dart';
import 'workout/workout_calendar_screen.dart';
```

- [ ] **Step 7: Verify**

```bash
flutter analyze lib/screens/foods_screen.dart
```

Expected: no errors.

- [ ] **Step 8: Commit**

```bash
git add lib/screens/foods_screen.dart
git commit -m "fix: clear scanned food on return, mounted guard, remove debugPrint, card standard"
```

---

## Task 9: Workout Calendar Screen — Replace Custom Color System + Fix Leaked State

**Files:**
- Modify: `lib/screens/workout/workout_calendar_screen.dart`

- [ ] **Step 1: Remove the six `late Color` class fields**

At the top of `_WorkoutCalendarScreenState`, delete:
```dart
// DELETE all six of these:
late Color _primaryColor;
late Color _secondaryColor;
late Color _accentColor;
late Color _textColor;
late Color _surfaceColor;
late Color _cardBorderColor;
late Color _iconColor;
```

- [ ] **Step 2: Remove the color initialization block from `build()`**

In `build()`, delete this entire block:
```dart
// DELETE:
_primaryColor = isDarkMode ? Colors.tealAccent.shade700 : Colors.blueGrey;
_secondaryColor = isDarkMode ? Colors.tealAccent : Colors.blueAccent;
_accentColor = isDarkMode ? Colors.tealAccent.shade400 : Colors.blue;
_textColor = isDarkMode ? Colors.white : Colors.black87;
_surfaceColor = isDarkMode ? const Color(0xFF303030) : Colors.white;
_cardBorderColor = isDarkMode
    ? Colors.tealAccent.withOpacity(0.3)
    : theme.colorScheme.outlineVariant.withOpacity(0.5);
_iconColor = isDarkMode ? Colors.tealAccent.shade200 : Colors.blueGrey;
```

- [ ] **Step 3: Replace all custom color field references with `colorScheme` tokens**

Add `final colorScheme = theme.colorScheme;` after `final theme = Theme.of(context);` in `build()`.

Make these substitutions throughout the file (use find & replace — each field appears multiple times):

| Old | New |
|-----|-----|
| `_primaryColor` | `colorScheme.primary` |
| `_secondaryColor` | `colorScheme.secondary` |
| `_accentColor` | `colorScheme.tertiary` |
| `_textColor` | `colorScheme.onSurface` |
| `_surfaceColor` | `colorScheme.surface` |
| `_cardBorderColor` | `colorScheme.secondary.withOpacity(0.3)` |
| `_iconColor` | `colorScheme.primary` |
| `Colors.white` (where used as text on colored background) | `colorScheme.onPrimary` |
| `const Color(0xFF1E1E1E)` | `colorScheme.surface` |
| `const Color(0xFF2A2A2A)` | `colorScheme.surfaceContainerHighest` |
| `const Color(0xFF202020)` | `colorScheme.surface` |
| `Colors.grey.shade900` | `colorScheme.surfaceContainerHighest` |
| `Colors.grey.shade100` | `colorScheme.surfaceContainerLowest` |
| `Colors.grey.shade800` | `colorScheme.outlineVariant` |
| `Colors.grey.shade200` | `colorScheme.outlineVariant` |
| `isDarkMode ? Colors.white : null` | `colorScheme.onSurface` |
| `isDarkMode ? Colors.white70 : null` | `colorScheme.onSurfaceVariant` |
| `isDarkMode ? Colors.redAccent : Colors.red` | `colorScheme.error` |
| `isDarkMode ? Colors.grey : Colors.grey.shade600` | `colorScheme.onSurfaceVariant` |
| `isDarkMode ? Colors.grey.shade400 : null` | `colorScheme.onSurfaceVariant` |
| `isDarkMode ? Colors.grey.shade600 : _primaryColor.withOpacity(0.3)` | `colorScheme.primary.withOpacity(0.3)` |
| `isDarkMode ? Colors.grey : _primaryColor.withOpacity(0.7)` | `colorScheme.onSurfaceVariant` |
| `isDarkMode ? Colors.grey : null` | `colorScheme.onSurfaceVariant` |
| `isDarkMode ? Colors.black : null` | `colorScheme.onPrimary` |
| `isDarkMode ? Colors.black38 : _primaryColor.withOpacity(0.1)` | `colorScheme.primary.withOpacity(0.1)` |
| `isDarkMode ? Colors.black26 : _primaryColor.withOpacity(0.05)` | `colorScheme.primary.withOpacity(0.05)` |
| `isDarkMode ? Colors.black45 : Colors.transparent` | `colorScheme.primary.withOpacity(0.05)` |
| `isDarkMode ? Colors.black38 : Colors.transparent` | `colorScheme.primary.withOpacity(0.05)` |
| `isDarkMode ? Colors.white24 : Colors.black12` | `colorScheme.outlineVariant` |

Also update the AppBar:
```dart
// FROM:
backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : null,

// TO:
backgroundColor: colorScheme.surface,
```

- [ ] **Step 4: Fix `_filteredWorkouts` leaked state — move it local to `StatefulBuilder`**

Remove `List<Map<String, dynamic>> _filteredWorkouts = [];` from the class fields.

Inside `_showWorkoutSelectionDialog`, change the variable from class-field usage to a local variable inside `StatefulBuilder`:

```dart
// BEFORE the showModalBottomSheet call, change:
_filteredWorkouts = List.from(_workouts);  // ← DELETE

// INSIDE StatefulBuilder builder:
builder: (BuildContext context, StateSetter setModalState) {
  // ADD this local variable at the top of the builder:
  List<Map<String, dynamic>> filteredWorkouts = List.from(_workouts);

  return Container(
    ...
    // Replace all _filteredWorkouts references inside this builder with filteredWorkouts
  );
}
```

Also update the `onChanged` handler inside the builder:
```dart
onChanged: (value) {
  setModalState(() {
    if (value.isEmpty) {
      filteredWorkouts = List.from(_workouts);  // was _filteredWorkouts
    } else {
      filteredWorkouts = _workouts.where((workout) {  // was _filteredWorkouts =
        final name = (workout['name'] as String).toLowerCase();
        final description = workout['description'] != null
            ? (workout['description'] as String).toLowerCase()
            : '';
        return name.contains(value.toLowerCase()) ||
            description.contains(value.toLowerCase());
      }).toList();
    }
  });
},
```

- [ ] **Step 5: Remove two `debugPrint` calls**

Find and delete:
```dart
debugPrint(workouts.toString());
```

Find and delete (replace the whole line, keeping the setState/error handling):
```dart
debugPrint('Failed to load workouts: ${e.toString()}');
```

- [ ] **Step 6: Remove `_onNavBarTap` and update `CustomBottomNavBar` call**

Delete the entire `_onNavBarTap` method. Update:
```dart
// FROM:
bottomNavigationBar: CustomBottomNavBar(
  currentIndex: _currentIndex,
  onTap: _onNavBarTap,
),

// TO:
bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex),
```

- [ ] **Step 7: Apply card standard to `_buildWorkoutCard`**

```dart
// FROM:
Card(
  margin: const EdgeInsets.only(bottom: 16),
  elevation: 0,
  color: isDarkMode ? const Color(0xFF2A2A2A) : null,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(
      color: isDarkMode
          ? _secondaryColor.withOpacity(0.3)
          : theme.colorScheme.outlineVariant.withOpacity(0.5),
      width: isDarkMode ? 1.5 : 1,
    ),
  ),
  ...
)

// TO:
Card(
  margin: const EdgeInsets.only(bottom: 16),
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    side: BorderSide(
      color: colorScheme.primary.withOpacity(0.15),
      width: 1,
    ),
  ),
  ...
)
```

- [ ] **Step 8: Verify**

```bash
flutter analyze lib/screens/workout/workout_calendar_screen.dart
```

Expected: no errors.

- [ ] **Step 9: Commit**

```bash
git add lib/screens/workout/workout_calendar_screen.dart
git commit -m "fix: workout screen uses colorScheme, fix filtered workouts leak, remove debugPrint"
```

---

## Task 10: Settings Screen — Fix Dead Variable + AppBar Standard

**Files:**
- Modify: `lib/screens/settings_screen.dart`

- [ ] **Step 1: Fix dead variable from `deleteAccount()`**

Find:
```dart
final data = await _apiService.deleteAccount();
```

Replace with:
```dart
await _apiService.deleteAccount();
```

- [ ] **Step 2: Apply AppBar standard**

Find:
```dart
appBar: AppBar(title: const Text('Settings')),
```

Replace with:
```dart
appBar: AppBar(
  title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
  elevation: 0,
  backgroundColor: Theme.of(context).colorScheme.surface,
  foregroundColor: Theme.of(context).colorScheme.onSurface,
),
```

- [ ] **Step 3: Verify**

```bash
flutter analyze lib/screens/settings_screen.dart
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/screens/settings_screen.dart
git commit -m "fix: settings dead variable, AppBar standard"
```

---

## Task 11: Rename `addBanner.dart` → `add_banner.dart`

**Files:**
- Rename: `lib/utils/addBanner.dart` → `lib/utils/add_banner.dart`

- [ ] **Step 1: Rename the file**

```bash
mv lib/utils/addBanner.dart lib/utils/add_banner.dart
```

- [ ] **Step 2: Update any imports**

Search for references to the old filename:
```bash
grep -r "addBanner" lib/
```

For each file found, update the import:
```dart
// FROM:
import '../utils/addBanner.dart';

// TO:
import '../utils/add_banner.dart';
```

- [ ] **Step 3: Verify**

```bash
flutter analyze
```

Expected: no errors across the whole project.

- [ ] **Step 4: Final build check**

```bash
flutter build apk --debug
```

Expected: BUILD SUCCESSFUL.

- [ ] **Step 5: Commit**

```bash
git add lib/utils/add_banner.dart
git rm lib/utils/addBanner.dart 2>/dev/null || true
git add -u
git commit -m "refactor: rename addBanner.dart to add_banner.dart (snake_case convention)"
```

---

## Self-Review

**Spec coverage check:**
- §1.1 Teal seed → Task 1 ✓
- §1.2 Scaffold background → Task 1 ✓
- §1.3 Card standard → Tasks 6, 7, 8, 9 ✓
- §1.4 AppBar standard → Tasks 4, 6, 7, 8, 10 ✓
- §1.5 Auth theme-aware → Tasks 4, 5 ✓
- §1.6 Workout color system → Task 9 ✓
- §2.1 Logout pop bug → Task 6 ✓
- §2.2 Profile logout nav stack → Task 7 ✓
- §2.3 `mounted` checks → Tasks 4, 5 ✓
- §2.4 Dead variable → Task 10 ✓
- §2.5 Scanned food clear → Task 8 ✓
- §2.6 `_filteredWorkouts` leak → Task 9 ✓
- §3.1 Nav duplication → Tasks 3, 6, 7, 8, 9 ✓
- §3.2 Shared AppTextField → Task 2 ✓
- §3.3 Dead code removal → Task 7 ✓
- §3.4 `mounted` in `_goToNewFood` → Task 8 ✓
- §3.5 `debugPrint` removal → Tasks 8, 9 ✓
- §3.6 Filename rename → Task 11 ✓
