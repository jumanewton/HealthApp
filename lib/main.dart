import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthmate/config/routes.dart';
import 'package:healthmate/pages/home_page.dart';
import 'package:healthmate/pages/onboarding_screens.dart';
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
            // User is logged in -> Go directly to HomePage
            return const HomePage();
          } else {
            // User is not logged in -> Show Onboarding
            return const OnboardingScreen();
          }
        },
      ),
      theme: lightMode,
      darkTheme: darkMode,
      routes: AppRoutes.routes, // Use modularized routes
    );
  }
}
