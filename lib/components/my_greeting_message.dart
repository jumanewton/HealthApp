import 'package:flutter/material.dart';

class MyGreetingMessage extends StatelessWidget {
  final String fullName; // Accept fullName instead of firstName

  const MyGreetingMessage({super.key, required this.fullName});

  // Method to extract the first name from the full name
  String getFirstName() {
    if (fullName.isEmpty) {
      return "User"; // Fallback value if fullName is empty
    }
    return fullName.trim().split(" ")[0];
  }

  // Method to get the appropriate greeting based on the time of day
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${getGreeting()}, ${getFirstName()}!", // Use extracted first name
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Last seen: 2 hours ago",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}