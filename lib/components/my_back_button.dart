import 'package:flutter/material.dart';

class MyBackButton extends StatelessWidget {
  const MyBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              // borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.inversePrimary,
            )));
  }
}
