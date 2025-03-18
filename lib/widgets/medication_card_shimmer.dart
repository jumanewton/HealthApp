// lib/widgets/medication_card_shimmer.dart
import 'package:flutter/material.dart';

class MedicationCardShimmer extends StatelessWidget {
  const MedicationCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  // Subtitle placeholder 1
                  Container(
                    width: 200,
                    height: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  // Subtitle placeholder 2
                  Container(
                    width: 150,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            // Action button placeholder
            Container(
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}