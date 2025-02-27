import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:healthmate/auth/auth.dart';
import 'package:healthmate/auth/login_or_register.dart';
import 'package:healthmate/pages/home_page.dart';
import 'package:healthmate/pages/noti_service.dart';
import 'package:healthmate/pages/profile_page.dart';
import 'package:healthmate/pages/settings_page.dart';
import 'package:healthmate/themes/dark_mode.dart';
import 'package:healthmate/themes/light_mode.dart';
import 'package:healthmate/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotiService().initNotification();
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
        '/login_register_page': (context) => LoginOrRegister(),
        '/home_page': (context) => HomePage(),
        '/profile_page': (context) => ProfilePage(),
        '/settings_page': (context) => SettingsPage(),

      },
    );
  }
}
