import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthmate/helper/helper_functions.dart';
import 'package:healthmate/pages/home_page.dart';
import 'package:healthmate/helper/alert_utils.dart';
import 'package:healthmate/widgets/background_container.dart';
import 'package:healthmate/widgets/styled_text_field.dart';
import 'package:healthmate/widgets/styled_button.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  // Text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  
  // Animation controller for transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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

      // Pop the loading indicator
      if (context.mounted) Navigator.pop(context);

      // Always navigate to HomePage, regardless of user data existence
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      displayError(context, e.message ?? "Login failed. Please try again.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      body: BackgroundContainer(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: _buildLoginCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
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
            _buildFormFields(),
            const SizedBox(height: 10),
            _buildForgotPassword(),
            const SizedBox(height: 25),
            StyledButton(
              text: _isLoading ? 'LOGGING IN...' : 'LOGIN',
              onPressed: _isLoading ? () {} : login,
            ),
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          child: Icon(
            Icons.health_and_safety,
            size: 50,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'H E A L T H M A T E',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Login to your account',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        StyledTextField(
          controller: emailController,
          hintText: "Email",
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 15),
        StyledTextField(
          controller: passwordController,
          hintText: "Password",
          prefixIcon: Icons.lock,
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: resetPassword,
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Don\'t have an account?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          TextButton(
            onPressed: widget.onTap,
            child: Text(
              "Register Here",
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