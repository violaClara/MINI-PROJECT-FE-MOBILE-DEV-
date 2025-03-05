import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/insight_screen.dart';
import 'controllers/auth_controller.dart';
import 'controllers/target_controller.dart';
import 'app_theme.dart';

/// Entry point of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
    await Hive.openBox('settings');
    // Initialize the database for the authentication controller.
    await AuthController.instance.initDatabase();
  } catch (e) {
    print("Error during initialization: $e");
  }

  // Retrieve the login state from Hive.
  var box = await Hive.openBox('settings');
  bool isLoggedIn = box.get('isLoggedIn', defaultValue: false);

  // If user is logged in, restore user data from the database.
  if (isLoggedIn) {
    await AuthController.instance.restoreUser();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider<AuthController>.value(value: AuthController.instance),
        Provider(create: (context) => TargetController()),
      ],
      child: MyApp(initialRoute: isLoggedIn ? '/home' : '/'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Work Habits',
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,  // Use the light theme from AppTheme
      darkTheme: AppTheme.darkTheme, // Use the dark theme from AppTheme

      // Define the named routes for the app.
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/insight': (context) => const InsightScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
