import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthmate/components/my_button.dart';
import 'package:healthmate/components/my_textfield.dart';
import 'package:healthmate/helper/helper_functions.dart';
import 'package:healthmate/pages/home_page.dart';
import 'package:healthmate/pages/multi_step_form.dart';
import 'package:healthmate/utility/firestore_utils.dart';
import 'package:healthmate/helper/alert_utils.dart';


class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  void login() async {
    if (_isLoading) return; // Prevent multiple taps

    setState(() => _isLoading = true);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing while loading
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Sign in the user
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());

      // Fetch user data from Firestore
      var userData = await FirestoreUtils.getUserData(userCredential.user!.email!);

      // Pop the loading indicator
      if (context.mounted) Navigator.pop(context);

      // Navigate based on profile completion
      if (userData != null && userData['username'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MultiStepForm(userId: userCredential.user!.uid)),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading dialog
      displayError(context, e.message ?? "Login failed. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void resetPassword() async {
    if (emailController.text.isEmpty) {
      displayError(context, "Enter your email to reset password.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim());
      displayMessage(context, "Password reset link sent to your email.");
    } catch (e) {
      displayError(context, "Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person,
                size: 80,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              const SizedBox(height: 25),
              const Text(
                'H E A L T H M A T E',
                style: TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 50),

              // Email input
              MyTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController),

              const SizedBox(height: 10),
              // Password input
              MyTextField(
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController),

              const SizedBox(height: 10),
              // Forgot password button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: resetPassword,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              // Login button (disable when loading)
              MyButton(
                text: _isLoading ? 'Logging in...' : 'Login',
                onTap: _isLoading ? null : login,
              ),

              const SizedBox(height: 10),
              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      " Register Here",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
