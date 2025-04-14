import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePictureSelector extends StatelessWidget {
  final Function(File) onImageSelected;
  final File? currentImage;

  const ProfilePictureSelector({
    super.key,
    required this.onImageSelected,
    this.currentImage,
  });

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      onImageSelected(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
            backgroundImage: currentImage != null
                ? FileImage(currentImage!) as ImageProvider
                : const AssetImage('assests/images/default_avatar.png'),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _pickProfilePicture,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
