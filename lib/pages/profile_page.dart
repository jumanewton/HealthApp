import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthmate/widgets/edit_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Get user details from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!.exists) {
              return Center(
                  child: Text('Error loading profile: ${snapshot.error}'));
            }

            final userData = snapshot.data!.data()!;
            return _buildProfileContent(context, userData);
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode
                ? Colors.tealAccent[200]
                : Theme.of(context).primaryColor,
            letterSpacing: 1.2,
          ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Map<String, dynamic> user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header with back button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                'My Profile',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _navigateToEditProfile(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Profile Picture Section
          _buildProfilePictureSection(context, user),

          const SizedBox(height: 32),

          // User Information Section
          _buildUserInfoSection(context, user),

          const SizedBox(height: 24),

          // Health Stats Section
          _buildHealthStatsSection(context, user),

          const SizedBox(height: 24),

          // Recent Activity Section
          _buildRecentActivitySection(context),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection(
      BuildContext context, Map<String, dynamic> user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: user['profilePicture'] != null
                    ? Image.network(
                        user['profilePicture'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 60),
                      )
                    : const Icon(Icons.person, size: 60),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _changeProfilePicture(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user['username'] ?? 'No username',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          user['email'] ?? 'No email',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection(
      BuildContext context, Map<String, dynamic> user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Personal Information'),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Full Name', user['fullName'] ?? 'Not set'),
            _buildInfoRow(context, 'Date of Birth', user['dob'] ?? 'Not set'),
            _buildInfoRow(context, 'Gender', user['gender'] ?? 'Not set'),
            _buildInfoRow(context, 'Location', user['location'] ?? 'Not set'),
            _buildInfoRow(context, 'Phone', user['phoneNumber'] ?? 'Not set'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatsSection(
      BuildContext context, Map<String, dynamic> user) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDarkMode ? Colors.grey[900] : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Health Stats'),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / 3 - 8;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(context, 'Height',
                        '${user['height'] ?? '--'} cm', itemWidth),
                    _buildStatItem(context, 'Weight',
                        '${user['weight'] ?? '--'} kg', itemWidth),
                    _buildStatItem(
                        context, 'BMI', _calculateBMI(user), itemWidth),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String title, String value, double width) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width * 0.8,
            height: width * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode
                  ? Colors.teal.withOpacity(0.2)
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              border: Border.all(
                color: isDarkMode
                    ? Colors.tealAccent.withOpacity(0.5)
                    : Theme.of(context).primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.tealAccent[100]
                              : Theme.of(context).primaryColor,
                          fontSize: 18,
                        ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  letterSpacing: 1.1,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  String _calculateBMI(Map<String, dynamic> user) {
    final height = user['height'] != null
        ? double.tryParse(user['height'].toString())
        : null;
    final weight = user['weight'] != null
        ? double.tryParse(user['weight'].toString())
        : null;

    if (height == null || weight == null || height == 0) return '--';

    final bmi = weight / ((height / 100) * (height / 100));
    return bmi.toStringAsFixed(1);
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildSectionTitle(context, 'Recent Activity'),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildActivityCard(
                  context, 'Workout', Icons.fitness_center, '30 min'),
              _buildActivityCard(
                  context, 'Steps', Icons.directions_walk, '5,240'),
              _buildActivityCard(context, 'Water', Icons.local_drink, '2.5 L'),
              _buildActivityCard(context, 'Sleep', Icons.bedtime, '7h 30m'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(
      BuildContext context, String title, IconData icon, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  Future<void> _changeProfilePicture(BuildContext context) async {
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Take Photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (result != null) {
      final pickedFile = await ImagePicker().pickImage(source: result);
      if (pickedFile != null) {
        // Upload to Firebase Storage and update profile
        final file = File(pickedFile.path);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('${currentUser!.uid}.jpg');

        try {
          // Show loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Uploading image...')));

          // Upload image
          final uploadTask = await storageRef.putFile(file);
          final downloadUrl = await uploadTask.ref.getDownloadURL();

          // Update user profile in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .update({'profilePicture': downloadUrl});

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile picture updated!')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating profile picture: $e')));
        }
      }
    }
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }
}
