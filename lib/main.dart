import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:healthmate/auth/auth.dart';
import 'package:healthmate/auth/login_or_register.dart';
import 'package:healthmate/pages/home_page.dart';
import 'package:healthmate/pages/notifications_page.dart';
import 'package:healthmate/pages/profile_page.dart';
import 'package:healthmate/pages/settings_page.dart';
import 'package:healthmate/pages/emergency_contact_page.dart'; // Add this
import 'package:healthmate/pages/symptom_checker_page.dart'; // Add this
import 'package:healthmate/pages/health_insights_page.dart'; // Add this
import 'package:healthmate/themes/dark_mode.dart';
import 'package:healthmate/themes/light_mode.dart';
import 'package:healthmate/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthmate/pages/calendar_page.dart'; // Add this


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // NotiService().initNotification(); // Uncomment if you have a notification service
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
      routes: {
        '/login_register_page': (context) => const LoginOrRegister(),
        '/home_page': (context) => const HomePage(),
        '/profile_page': (context) => ProfilePage(),
        '/settings_page': (context) => const SettingsPage(),
        '/emergency_contact_page': (context) => const EmergencyContactPage(), // Add this
        '/symptom_checker_page': (context) => const SymptomCheckerPage(), // Add this
        '/health_insights_page': (context) => const HealthInsightsPage(), // Add this
        '/notifications_page': (context) => const NotificationsPage(), // Add this
        '/calendar_page': (context) => const CalendarPage(), // Add this
      },
    );
  }
}