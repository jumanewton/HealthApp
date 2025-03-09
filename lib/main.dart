import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:healthmate/auth/login_or_register.dart';
import 'package:healthmate/pages/calendar_page.dart';
import 'package:healthmate/pages/emergency_contact_page.dart';
import 'package:healthmate/pages/health_insights_page.dart';
import 'package:healthmate/pages/home_page.dart';
import 'package:healthmate/pages/multi_step_form.dart';
import 'package:healthmate/pages/notifications_page.dart';
import 'package:healthmate/pages/onboarding_screens.dart';
import 'package:healthmate/pages/profile_page.dart';
import 'package:healthmate/pages/settings_page.dart';
import 'package:healthmate/pages/symptom_checker_page.dart';
import 'package:healthmate/themes/dark_mode.dart';
import 'package:healthmate/themes/light_mode.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData) {
            // User is logged in
            final userId = FirebaseAuth.instance.currentUser!.uid;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  // User has completed the multi-step form
                  return const HomePage();
                } else {
                  // User hasn't completed the multi-step form
                  return MultiStepForm(userId: userId);
                }
              },
            );
          } else {
            // User is not logged in
            return const OnboardingScreen(); // Start with onboarding
          }
        },
      ),
      theme: lightMode, // Use your custom light theme
      darkTheme: darkMode, // Use your custom dark theme
      routes: {
        '/login_register_page': (context) => const LoginOrRegister(),
        '/home_page': (context) => const HomePage(),
        '/profile_page': (context) => ProfilePage(),
        '/settings_page': (context) => const SettingsPage(),
        '/emergency_contact_page': (context) => const EmergencyContactPage(),
        '/symptom_checker_page': (context) => const SymptomCheckerPage(),
        '/health_insights_page': (context) => const HealthInsightsPage(),
        '/notifications_page': (context) => const NotificationsPage(),
        '/calendar_page': (context) => const CalendarPage(),
        '/multi-step-form': (context) => MultiStepForm(
            userId: FirebaseAuth.instance.currentUser?.uid ?? 'testUserId'),
        '/onboarding': (context) =>
            const OnboardingScreen(), // Add onboarding route
      },
    );
  }
}
