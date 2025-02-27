import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? profilePicture;

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profilePicture = pickedFile.path;
      });
    }
  }

  void _changePassword() {
    // Implement password change functionality
  }

  void _toggleTheme(bool isDarkMode) {
    // Implement theme toggling logic here
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
                backgroundImage: profilePicture != null
                    ? AssetImage(profilePicture!)
                    : const AssetImage('assets/default_profile.png'),
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
          
          // Modify Emergency Contacts
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Emergency Contacts'),
            onTap: () => Navigator.pushNamed(context, '/emergency_contacts'),
          ),
          
          // Theme Toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: _toggleTheme,
          ),
        ],
      ),
    );
  }
}
