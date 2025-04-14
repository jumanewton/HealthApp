import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthmate/services/auth_service.dart';
import 'package:healthmate/services/theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _profilePicture;
  bool _isDarkMode = false;
  final TextEditingController _feedbackController = TextEditingController();

  // Contact information
  final String supportEmail = 'barasanewton62@gmail.com';
  final String supportPhone = '0745210329';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
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

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: 'subject=HealthMate Support Request',
    );

    try {
      await launchUrl(emailUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch email: $e')),
      );
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: supportPhone.replaceAll(RegExp(r'\D'), ''),
    );

    try {
      await launchUrl(phoneUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch phone: $e')),
      );
    }
  }

  void _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback')),
      );
      return;
    }

    try {
      await _firestore.collection('feedback').add({
        'userId': _auth.currentUser?.uid,
        'userEmail': _auth.currentUser?.email,
        'feedback': _feedbackController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _feedbackController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback: $e')),
      );
    }
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: _feedbackController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Tell us what you think about HealthMate...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _submitFeedback,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
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

          // Delete Account
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

          // Theme Toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: Provider.of<ThemeProvider>(context).isDarkMode,
            onChanged: (value) =>
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme(value),
          ),

          const Divider(),

          // Contact Us Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Email
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email Support'),
            subtitle: Text(supportEmail),
            onTap: _launchEmail,
          ),

          // Phone
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Call Support'),
            subtitle: Text(supportPhone),
            onTap: _launchPhone,
          ),

          // Feedback
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Send Feedback'),
            subtitle: const Text('Help us improve HealthMate'),
            onTap: _showFeedbackDialog,
          ),
        ],
      ),
    );
  }
}
