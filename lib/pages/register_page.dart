import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthmate/components/my_button.dart';
import 'package:healthmate/components/my_textfield.dart';
import 'package:healthmate/helper/helper_functions.dart';
import 'package:healthmate/pages/multi_step_form.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPwController = TextEditingController();

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

      // Get the user ID
      String userId = userCredential.user!.uid;

      // Add the user to the Firestore database
      await createUserDocument(userCredential);

      // Pop the loading indicator
      if (context.mounted) Navigator.pop(context);

      // Navigate to the MultiStepForm page
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MultiStepForm(userId: userId),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Pop the loading indicator
      displayError(context, e.message!);
    }
  }


  // create a user document in the cloud firestore database
  Future<void> createUserDocument(UserCredential userCredential) async {
    if (userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': usernameController.text,
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
                // logo
                Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 25),
                // app name
                Text(
                  'H E A L T H M A T E',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 50),
                // Username input
                MyTextField(
                    hintText: "Username",
                    obscureText: false,
                    controller: usernameController),

                // email input
                const SizedBox(height: 10),
                MyTextField(
                    hintText: "Email",
                    obscureText: false,
                    controller: emailController),

                // password input
                const SizedBox(height: 10),
                MyTextField(
                    hintText: "Password",
                    obscureText: true,
                    controller: passwordController),

                // confirm password input
                const SizedBox(height: 10),
                MyTextField(
                    hintText: "Confirm Password",
                    obscureText: true,
                    controller: confirmPwController),

                // forgot password button
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                // Register button
                const SizedBox(height: 25),
                MyButton(text: 'Register', onTap: register),
                // already have an account button
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
