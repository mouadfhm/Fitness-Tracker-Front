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
// import 'screens/splash_screen.dart';
import 'screens/foods_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/workout_root_screen.dart';
import 'services/token_service.dart';
import 'services/navigation_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  // TODO: replace with your real device ID from the debug log, then remove before release
  // Look for: I/Ads: Use RequestConfiguration.Builder.setTestDeviceIds(Arrays.asList("XXXX..."))
  await MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: const ['46D8C6F5BCE25D727A17714F6B082BE8']),
  );
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
    // Use the ThemeProvider from Provider to get the current theme mode
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
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
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/workouts': (_) => const WorkoutRootScreen(),
        '/foods': (_) => const FoodsScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
      // home: SplashScreen(
      //   nextScreen: isLoggedIn ? const HomeScreen() : const LoginScreen(),
      // ),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
