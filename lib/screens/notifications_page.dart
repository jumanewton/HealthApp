import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../widgets/notification_card.dart';
import '../providers/notification_provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await notificationProvider.markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationProvider.notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications = snapshot.data;
          
          if (notifications == null || notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Dismissible(
                key: Key(notification.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Notification'),
                      content: const Text(
                          'Are you sure you want to delete this notification?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('DELETE'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  notificationProvider.deleteNotification(notification.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification deleted')),
                  );
                },
                child: NotificationCard(
                  notification: notification,
                  onTap: () {
                    // Mark as read
                    if (!notification.isRead) {
                      notificationProvider.markAsRead(notification.id);
                    }
                    
                    // Handle notification tap based on type
                    if (notification.type == 'Medication' && 
                        notification.additionalData != null &&
                        notification.additionalData!.containsKey('medicationId')) {
                      // Navigate to medication details
                      // Navigator.push(...);
                    } else if (notification.type == 'Health Tip' && 
                              notification.additionalData != null) {
                      // Navigate to health insight details
                      // Navigator.push(...);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}