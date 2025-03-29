import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthmate/services/auth_service.dart';
import 'package:healthmate/services/theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

// Import themes

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _profilePicture;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _profilePicture = prefs.getString('profilePicture');
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    if (_profilePicture != null) {
      prefs.setString('profilePicture', _profilePicture!);
    }
  }

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePicture = pickedFile.path;
      });
      _savePreferences();
    }
  }

  void _changePassword() async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      try {
        await _auth.sendPasswordResetEmail(email: user.email!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send password reset email: $e')),
        );
      }
    }
  }

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
    });
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Picture
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profilePicture != null
                    ? FileImage(File(_profilePicture!)) as ImageProvider
                    : const AssetImage('assests/images/profile1.png'),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Username & Email
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(user?.displayName ?? 'User Name'),
            subtitle: Text(user?.email ?? 'Email'),
          ),

          const Divider(),

          // Change Password
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: _changePassword,
          ),

          // Logout

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout?'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await AuthService().signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
          // const SizedBox(height: 20),

          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Account'),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Account?'),
                  content:
                      const Text('This will permanently erase all your data.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await AuthService().deleteAccount();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          const SizedBox(height: 20),
          // Theme Toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: Provider.of<ThemeProvider>(context).isDarkMode,
            onChanged: (value) =>
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme(value),
          ),
        ],
      ),
    );
  }
}
