import 'package:flutter/material.dart';
import 'package:healthmate/components/my_greeting_message.dart';
import 'package:healthmate/components/my_quick_access_tile.dart';
import 'package:healthmate/pages/medication_page.dart';
import 'package:healthmate/pages/emergency_contact_page.dart';
import 'package:healthmate/pages/symptom_checker_page.dart';
import 'package:healthmate/pages/health_records_page.dart';
import 'package:healthmate/pages/health_insights_page.dart';

class HomeContent extends StatelessWidget {
  final String fullName; // Accept fullName instead of firstName

  const HomeContent({super.key, required this.fullName}); // Updated constructor

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Welcome Message & Profile Overview
        MyGreetingMessage(fullName: fullName), // Pass fullName to MyGreetingMessage

        // Quick Access Tiles
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            MyQuickAccessTile(
              icon: Icons.medical_services,
              title: "Medication Tracker",
              subtitle: "Next: Paracetamol at 2:00 PM",
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MedicationPage(),
                  ),
                );
              },
            ),
            MyQuickAccessTile(
              icon: Icons.emergency,
              title: "Emergency Contact",
              subtitle: "Call Dr. Smith",
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyContactPage(),
                  ),
                );
              },
            ),
            MyQuickAccessTile(
              icon: Icons.health_and_safety,
              title: "Symptom Checker",
              subtitle: "Check your symptoms",
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SymptomCheckerPage(),
                  ),
                );
              },
            ),
            MyQuickAccessTile(
              icon: Icons.folder,
              title: "Health Records",
              subtitle: "Last Upload: Jan 2024",
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HealthRecordsPage(),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Health Insights & Reminders
        const Text(
          "Health Insights & Reminders",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.health_and_safety, color: Colors.blue),
            title: const Text("Ongoing Treatment: Diabetes Management"),
            subtitle: const Text("Next checkup: Feb 15, 2024"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HealthInsightsPage(),
                ),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.water_drop, color: Colors.blue),
            title: const Text("Hydration Reminder"),
            subtitle: const Text("Drink 8 glasses of water today!"),
          ),
        ),

        const SizedBox(height: 20),

        // Notification Center
        const Text(
          "Notifications",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications, color: Colors.red),
            title: const Text("Missed Medication"),
            subtitle: const Text("Paracetamol at 10:00 AM"),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.green),
            title: const Text("Upcoming Appointment"),
            subtitle: const Text("Dr. Smith at 3:00 PM"),
          ),
        ),
      ],
    );
  }
}