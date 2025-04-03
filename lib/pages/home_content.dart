import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthmate/helper/last_update.dart';
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
import 'package:healthmate/models/notification_model.dart';

class HomeContent extends StatelessWidget {
  final String fullName;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  HomeContent({super.key, required this.fullName});

  @override
  Widget build(BuildContext context) {
    // Access the notification provider
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Welcome Message & Profile Overview
          MyGreetingMessage(fullName: fullName),

          const SizedBox(height: 20),

          // Quick Access Tiles
          const Text(
            "Quick Access",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

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
                subtitle: "Check your medications",
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
                subtitle: "Make a call",
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
                subtitle: "View your records",
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
      ),
    );
  }
}

class HealthInsightsSection extends StatelessWidget {
  const HealthInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
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

        // Dynamic insights from provider
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final healthInsights = provider.notifications
                .where((notification) =>
                    notification.type == NotificationType.healthTip)
                .take(2)
                .toList();

            if (healthInsights.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              children: healthInsights
                  .map((insight) => Card(
                        margin: const EdgeInsets.only(top: 8),
                        child: ListTile(
                          leading:
                              const Icon(Icons.insights, color: Colors.green),
                          title: Text(insight.title),
                          subtitle: Text(insight.body),
                          trailing: Text(_getTimeAgo(insight.timestamp)),
                          onTap: () {
                            if (!insight.isRead) {
                              provider.markAsRead(insight.id);
                            }
                          },
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  // Helper method to format time ago
  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                child: const Text("See All"),
              ),
            ],
          ),
        ),

        // Display notifications from provider
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final recentNotifications = provider.notifications
                .where((notification) =>
                    notification.type != NotificationType.healthTip)
                .take(3)
                .toList();

            if (recentNotifications.isEmpty) {
              return Card(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: const Text(
                    "No new notifications",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return Column(
              children: recentNotifications
                  .map((notification) => Card(
                        margin: const EdgeInsets.only(top: 8),
                        color: notification.isRead ? null : Colors.blue.shade50,
                        child: ListTile(
                          leading: _getNotificationIcon(notification.type),
                          title: Text(notification.title),
                          subtitle: Text(notification.body),
                          trailing: Text(_getTimeAgo(notification.timestamp)),
                          onTap: () {
                            if (!notification.isRead) {
                              provider.markAsRead(notification.id);
                            }

                            // Navigate based on notification type
                            _handleNotificationTap(context, notification);
                          },
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  void _handleNotificationTap(
      BuildContext context, NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.medication:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MedicationsPage(),
          ),
        );
        break;
      case NotificationType.appointment:
        // Navigate to appointments page
        break;
      case NotificationType.healthTip:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HealthInsightsPage(),
          ),
        );
        break;
      case NotificationType.general:
      default:
        // No specific navigation
        break;
    }
  }

  // Helper method to get icon based on notification type
  Widget _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.medication:
        return const Icon(Icons.medication, color: Colors.blue);
      case NotificationType.appointment:
        return const Icon(Icons.calendar_today, color: Colors.purple);
      case NotificationType.healthTip:
        return const Icon(Icons.lightbulb, color: Colors.amber);
      case NotificationType.general:
      default:
        return const Icon(Icons.notifications, color: Colors.grey);
    }
  }

  // Helper method to format time ago
  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
