import 'package:flutter/material.dart';
import 'package:healthmate/auth/login_or_register.dart';
import 'package:healthmate/pages/calendar_page.dart';
import 'package:healthmate/pages/emergency_contact_page.dart';
import 'package:healthmate/pages/health_insights_page.dart';
import 'package:healthmate/pages/home_page.dart';
import 'package:healthmate/pages/notifications_page.dart';
import 'package:healthmate/pages/onboarding_screens.dart';
import 'package:healthmate/pages/profile_page.dart';
import 'package:healthmate/pages/settings_page.dart';
import 'package:healthmate/pages/symptom_checker_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login_register_page': (context) => const LoginOrRegister(),
    '/home_page': (context) => const HomePage(),
    '/profile_page': (context) => ProfilePage(),
    '/settings_page': (context) => const SettingsPage(),
    '/emergency_contact_page': (context) => const EmergencyContactPage(),
    '/symptom_checker_page': (context) => const SymptomCheckerPage(),
    '/health_insights_page': (context) => const HealthInsightsPage(),
    '/notifications_page': (context) => const NotificationsPage(),
    '/calendar_page': (context) => const CalendarPage(),
    '/onboarding': (context) => const OnboardingScreen(),
    
    
  };
}
