import 'package:flutter/material.dart';

class DisclaimerCard extends StatelessWidget {
  const DisclaimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current theme brightness to check if we're in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Choose appropriate colors based on theme
    final cardBackgroundColor = isDarkMode
        ? Colors.orange.shade900.withOpacity(0.2)
        : Colors.orange.shade50;

    final textColor = isDarkMode ? Colors.orange.shade100 : Colors.black87;

    final titleColor = Colors.orange.shade700;

    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Important Disclaimer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'This AI symptom checker provides preliminary information only and is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.',
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
