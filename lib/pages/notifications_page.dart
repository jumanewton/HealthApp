import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  // Dummy data for notifications (replace with Firebase data)
  final List<Map<String, String>> notifications = const [
    {
      'type': 'Medication',
      'title': 'Missed Medication',
      'description': 'You missed your Paracetamol dose at 10:00 AM.',
      'time': '2 hours ago',
    },
    {
      'type': 'Appointment',
      'title': 'Upcoming Appointment',
      'description': 'You have an appointment with Dr. Smith at 3:00 PM.',
      'time': '5 hours ago',
    },
    {
      'type': 'Health Tip',
      'title': 'Hydration Reminder',
      'description': 'You’ve only had 4 glasses of water today. Drink more!',
      'time': '1 day ago',
    },
    {
      'type': 'Warning',
      'title': 'High Heart Rate',
      'description': 'Your heart rate was unusually high during your last workout.',
      'time': '2 days ago',
    },
  ];

  // Function to get the icon based on notification type
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'Medication':
        return Icons.medical_services;
      case 'Appointment':
        return Icons.calendar_today;
      case 'Health Tip':
        return Icons.health_and_safety;
      case 'Warning':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  // Function to get the icon color based on notification type
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'Medication':
        return Colors.red;
      case 'Appointment':
        return Colors.blue;
      case 'Health Tip':
        return Colors.green;
      case 'Warning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              leading: Icon(
                _getNotificationIcon(notification['type']!),
                color: _getNotificationColor(notification['type']!),
                size: 40,
              ),
              title: Text(notification['title']!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification['description']!),
                  const SizedBox(height: 4),
                  Text(
                    notification['time']!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              onTap: () {
                // Handle notification tap (e.g., mark as read, view details)
              },
            ),
          );
        },
      ),
    );
  }
}