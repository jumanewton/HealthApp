import 'package:flutter/material.dart';
import 'package:healthmate/models/notification_model.dart';
import 'package:provider/provider.dart';
import 'package:healthmate/components/my_greeting_message.dart';
import 'package:healthmate/components/my_quick_access_tile.dart';
import 'package:healthmate/pages/emergency_contact_page.dart';
import 'package:healthmate/pages/symptom_checker_page.dart';
import 'package:healthmate/pages/health_records_page.dart';
import 'package:healthmate/pages/health_insights_page.dart';
import 'package:healthmate/screens/medication_page.dart';
import 'package:healthmate/screens/notifications_page.dart';
import 'package:healthmate/providers/notification_provider.dart';

class HomePage extends StatelessWidget {
  final String fullName;

  const HomePage({super.key, required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthMate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: HomeContent(fullName: fullName),
    );
  }
}

class HomeContent extends StatelessWidget {
  final String fullName;

  const HomeContent({super.key, required this.fullName});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Welcome Message & Profile Overview
        MyGreetingMessage(fullName: fullName),

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
                    builder: (context) => const MedicationsPage(),
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
        const HealthInsightsSection(),

        const SizedBox(height: 20),

        // Notification Center
        const NotificationsSection(),
      ],
    );
  }
}

class HealthInsightsSection extends StatelessWidget {
  const HealthInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Health Insights & Reminders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => const HealthInsightsPage(),
                    ),
                  );
                },
                child: const Text("See All"),
              ),
            ],
          ),
        ),
        
        // Fixed insights
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
        
        // Dynamic insights from Firebase
        StreamBuilder<List<NotificationModel>>(
          stream: notificationProvider.notifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            final healthInsights = snapshot.data!
                .where((notification) => notification.type == 'Health Tip')
                .take(2)
                .toList();

            if (healthInsights.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              children: healthInsights.map((insight) => Card(
                margin: const EdgeInsets.only(top: 8),
                child: ListTile(
                  leading: const Icon(Icons.insights, color: Colors.green),
                  title: Text(insight.title),
                  subtitle: Text(insight.description),
                  trailing: Text(insight.timeAgo),
                  onTap: () {
                    if (!insight.isRead) {
                      notificationProvider.markAsRead(insight.id);
                    }
                    
                    // Navigate to details page if needed
                  },
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }
}

class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Notifications",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  );
                },
                child: const Text("See All"),
              ),
            ],
          ),
        ),
        
        // Display static notifications
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
        
        // Dynamic notifications from Firebase
        StreamBuilder<List<NotificationModel>>(
          stream: notificationProvider.notifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 0);
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink(); // Corrected
            }


            final recentNotifications = snapshot.data!
                .where((notification) => notification.type != 'Health Tip')
                .take(2)
                .toList();

            if (recentNotifications.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              children: recentNotifications.map((notification) => Card(
                margin: const EdgeInsets.only(top: 8),
                child: ListTile(
                  leading: Icon(
                    notification.type == 'Medication' ? Icons.medication :
                    notification.type == 'Appointment' ? Icons.calendar_today :
                    notification.type == 'Warning' ? Icons.warning_amber :
                    Icons.notifications,
                    color: notification.type == 'Medication' ? Colors.blue :
                           notification.type == 'Appointment' ? Colors.purple :
                           notification.type == 'Warning' ? Colors.orange :
                           Colors.grey,
                  ),
                  title: Text(notification.title),
                  subtitle: Text(notification.description),
                  trailing: Text(notification.timeAgo),
                  onTap: () {
                    if (!notification.isRead) {
                      notificationProvider.markAsRead(notification.id);
                    }
                    
                    // Navigate to appropriate page based on notification type
                    if (notification.type == 'Medication' && 
                        notification.additionalData != null &&
                        notification.additionalData!.containsKey('medicationId')) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MedicationsPage(),
                        ),
                      );
                    }
                  },
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }
}