
// File: lib/pages/register_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:healthmate/pages/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Import our custom widgets
import 'package:healthmate/widgets/background_container.dart';
import 'package:healthmate/widgets/profile_picture_selector.dart';
import 'package:healthmate/widgets/styled_text_field.dart';
import 'package:healthmate/widgets/styled_button.dart';
import 'package:healthmate/helper/helper_functions.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  // Text controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();
  
  // Animation controller for transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Profile picture
  File? _profilePicture;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    dateOfBirthController.dispose();
    genderController.dispose();
    passwordController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

  // Date picker for Date of Birth
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        dateOfBirthController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  // Image picker for Profile Picture
  void _updateProfilePicture(File image) {
    setState(() {
      _profilePicture = image;
    });
  }

  // Registration logic
  Future<void> register() async {
    // Show a loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Check if the passwords match
    if (passwordController.text != confirmPwController.text) {
      if (!context.mounted) return;
      Navigator.pop(context); // Pop the loading indicator
      displayError(context, "Passwords do not match");
      return;
    }

    try {
      // Create the user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Add the user to the Firestore database
      await createUserDocument(userCredential);

      // Pop the loading indicator and navigate directly to HomePage
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      displayError(context, e.message!);
    }
  }

  // Create a user document in the Cloud Firestore database
  Future<void> createUserDocument(UserCredential userCredential) async {
    if (userCredential.user == null) return;
    
    // Upload profile picture to Firebase Storage (if selected)
    String? profilePictureUrl;
    if (_profilePicture != null) {
      profilePictureUrl = await uploadImage(_profilePicture!);
      if (profilePictureUrl == null && context.mounted) {
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
      'profilePictureUrl': profilePictureUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = "profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: _buildRegistrationCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            
            ProfilePictureSelector(
              onImageSelected: _updateProfilePicture,
              currentImage: _profilePicture,
            ),
            const SizedBox(height: 30),
            
            _buildFormFields(),
            const SizedBox(height: 30),
            
            StyledButton(
              text: 'CREATE ACCOUNT',
              onPressed: register,
            ),
            
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'H E A L T H M A T E',
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        StyledTextField(
          controller: fullNameController,
          hintText: "Full Name",
          prefixIcon: Icons.person,
        ),
        const SizedBox(height: 15),
        
        StyledTextField(
          controller: emailController,
          hintText: "Email",
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 15),
        
        StyledTextField(
          controller: phoneNumberController,
          hintText: "Phone Number",
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 15),
        
        StyledTextField(
          controller: dateOfBirthController,
          hintText: "Date of Birth",
          prefixIcon: Icons.calendar_today,
          readOnly: true,
          suffixIcon: Icons.date_range,
          onSuffixIconPressed: () => _selectDateOfBirth(context),
        ),
        const SizedBox(height: 15),
        
        StyledTextField(
          controller: genderController,
          hintText: "Gender",
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 15),
        
        StyledTextField(
          controller: passwordController,
          hintText: "Password",
          prefixIcon: Icons.lock,
          obscureText: true,
        ),
        const SizedBox(height: 15),
        
        StyledTextField(
          controller: confirmPwController,
          hintText: "Confirm Password",
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          TextButton(
            onPressed: widget.onTap,
            child: Text(
              "Login Here",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          )
        ],
      ),
    );
  }
}
