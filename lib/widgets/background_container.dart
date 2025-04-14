import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;

  const BackgroundContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Gradient background
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE0F7FA), // Light cyan
            Color(0xFFB2EBF2), // Cyan
            Color(0xFF80DEEA), // Light blue
          ],
        ),
      ),
      // Background image with overlay
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assests/images/h_bg1.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.8),
              BlendMode.lighten,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
