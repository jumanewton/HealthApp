import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthmate/config/routes.dart';
import 'package:healthmate/pages/home_page.dart';
import 'package:healthmate/pages/onboarding_screens.dart';
import 'package:healthmate/providers/notification_provider.dart';
import 'package:healthmate/services/notification_service.dart';
import 'package:healthmate/services/theme_provider.dart';
import 'package:healthmate/themes/dark_mode.dart';
import 'package:healthmate/themes/light_mode.dart';
import 'package:healthmate/services/groq_service.dart';
import 'package:healthmate/providers/chat_provider.dart';
import 'package:healthmate/repositories/notification_repository.dart';


import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load();
  final notificationRepository = NotificationRepository();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Android Alarm Manager
  await AndroidAlarmManager.initialize();

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.init();

  // Create services that will be used across the app
  final groqService = GroqService(apiKey: dotenv.env['GROQ_API_KEY'] ?? '');

  runApp(
    MultiProvider(
      providers: [
        // Firebase Auth Stream Provider
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),

        // Initialize and provide NotificationProvider
       ChangeNotifierProvider(
          create: (_) => NotificationProvider(
            // notificationService:,
            repository: notificationRepository,
            notificationService: notificationService,
          ),
        ),

        // Chat Provider
        ChangeNotifierProvider(
          create: (_) => ChatProvider(groqService: groqService),
        ),

        // Theme Provider (Manages light/dark mode)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the auth state from StreamProvider
    final user = context.watch<User?>();
    
    // Get theme state from ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user == null ? const OnboardingScreen() : const HomePage(),

      // Dynamic theme switching
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routes: AppRoutes.routes,

      builder: (context, child) {
        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: child ?? const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
