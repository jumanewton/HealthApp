// lib/widgets/profile_picture_picker.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicturePicker extends StatelessWidget {
  final String? imagePath;
  final Function(String) onImagePicked;

  const ProfilePicturePicker({
    super.key, 
    this.imagePath, 
    required this.onImagePicked,
  });

  Future<void> _pickImage(BuildContext context) async {  // Add context parameter
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        onImagePicked(pickedFile.path);
      }
    } catch (e) {
      if (context.mounted) {  // Check if widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),  // Pass context here
      child: CircleAvatar(
        radius: 50,
        backgroundImage: imagePath != null
            ? FileImage(File(imagePath!))
            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
      ),
    );
  }
}