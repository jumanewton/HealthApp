import 'package:flutter/material.dart';

class StyledButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;
  
  const StyledButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 55,
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
        minimumSize: Size(double.infinity, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}