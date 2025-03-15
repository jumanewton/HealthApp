import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:healthmate/components/my_button.dart';
import 'package:healthmate/components/my_textfield.dart';
import 'package:healthmate/helper/helper_functions.dart';
import 'package:healthmate/pages/multi_step_form.dart';
import 'package:image_picker/image_picker.dart'; // For profile picture
import 'dart:io'; // For handling file paths

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text controllers
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPwController = TextEditingController();

  // Profile picture
  File? _profilePicture;

  // Date picker for Date of Birth
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dateOfBirthController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  // Image picker for Profile Picture
  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path);
      });
    }
  }

  Future<void> register() async {
    // Show a loading circle
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Check if the passwords match
    if (passwordController.text != confirmPwController.text) {
      Navigator.pop(context); // Pop the loading indicator
      displayError(context, "Passwords do not match");
      return;
    }

    try {
      // Create the user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Add the user to the Firestore database
      await createUserDocument(userCredential);

      // Pop the loading indicator
      if (context.mounted) Navigator.pop(context);

      // Navigate to the MultiStepForm page
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MultiStepForm(userId: userCredential.user!.uid),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Pop the loading indicator
      displayError(context, e.message!);
    }
  }

  // Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = "profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl; // Save this URL in Firestore or Realtime Database
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Create a user document in the Cloud Firestore database
  Future<void> createUserDocument(UserCredential userCredential) async {
    if (userCredential.user != null) {
      // Upload profile picture to Firebase Storage (if selected)
      String? profilePictureUrl;
      if (_profilePicture != null) {
        profilePictureUrl = await uploadImage(_profilePicture!);
        if (profilePictureUrl == null) {
          // Handle the case where the upload fails
          displayError(context, "Failed to upload profile picture");
          return;
        }
      }

      // Add user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'fullName': fullNameController.text,
        'email': userCredential.user!.email,
        'phoneNumber': phoneNumberController.text,
        'dateOfBirth': dateOfBirthController.text,
        'gender': genderController.text,
        'profilePictureUrl': profilePictureUrl, // Optional
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 25),
                // App name
                Text(
                  'H E A L T H M A T E',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 50),

                // Full Name input
                MyTextField(
                    hintText: "Full Name",
                    obscureText: false,
                    controller: fullNameController),

                // Email input
                const SizedBox(height: 10),
                MyTextField(
                    hintText: "Email",
                    obscureText: false,
                    controller: emailController),

                // Phone Number input
                const SizedBox(height: 10),
                MyTextField(
                    hintText: "Phone Number",
                    obscureText: false,
                    controller: phoneNumberController),

                // Date of Birth input with date picker
                const SizedBox(height: 10),
                TextField(
                  controller: dateOfBirthController,
                  decoration: InputDecoration(
                    hintText: "Date of Birth (YYYY-MM-DD)",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDateOfBirth(context),
                    ),
                  ),
                  readOnly: true, // Prevent manual input
                ),

                // Gender input
                const SizedBox(height: 10),
                MyTextField(
                    hintText: "Gender",
                    obscureText: false,
                    controller: genderController),

                // Password input
                const SizedBox(height: 10),
                MyTextField(
                    hintText: "Password",
                    obscureText: true,
                    controller: passwordController),

                // Confirm Password input
                const SizedBox(height: 10),
                MyTextField(
                    hintText: "Confirm Password",
                    obscureText: true,
                    controller: confirmPwController),

                // Profile Picture upload
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickProfilePicture,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt),
                        SizedBox(width: 10),
                        Text(
                          _profilePicture == null
                              ? "Upload Profile Picture (Optional)"
                              : "Profile Picture Selected",
                        ),
                      ],
                    ),
                  ),
                ),

                // Register button
                const SizedBox(height: 25),
                MyButton(text: 'Register', onTap: register),

                // Already have an account button
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Login Here",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}