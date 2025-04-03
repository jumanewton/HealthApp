import 'package:flutter/material.dart';
import 'package:healthmate/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_card.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  // void initState() {
  //   super.initState();
  //   // Load notifications when screen opens
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     // Get the user ID from your authentication service
  //     final authService = AuthService();
  //     final user = await authService.getCurrentUser();
  //     final userId = user?.uid; // Get UID if user is logged in

  //     if (userId != null) {
  //       Provider.of<NotificationProvider>(context, listen: false).init();
  //     }
  //   });
  // }
  // @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = (await AuthService().getCurrentUser())?.uid;
      if (userId != null && mounted) {
        Provider.of<NotificationProvider>(context, listen: false)
            .init(userId: userId); // Pass userId here
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.notifications.isEmpty) {
                return const SizedBox.shrink();
              }
              return PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'mark_read',
                    child: const Text('Mark all as read'),
                    onTap: () => provider.markAllAsRead(),
                  ),
                  PopupMenuItem(
                    value: 'clear',
                    child: const Text('Clear all'),
                    onTap: () => provider.clearAllNotifications(),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.init(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return Dismissible(
                    key: Key(notification.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      provider.deleteNotification(notification.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Notification deleted'),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () {
                              // This is where you would implement undo functionality
                              // provider.init();
                              provider.createNotification(
                                title: notification.title,
                                body: notification.body,
                                type: notification.type,
                                payload: notification.payload,
                              );
                            },
                          ),
                        ),
                      );
                    },
                    child: NotificationCard(
                      notification: notification,
                      onTap: () {
                        _handleNotificationTap(notification);
                        
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      Provider.of<NotificationProvider>(context, listen: false)
          .markAsRead(notification.id);
    }

    // Navigate based on notification type/payload if needed
    if (notification.payload != null) {
      switch (notification.type) {
        case NotificationType.medication:
          // Navigate to medication details
          Navigator.of(context).pushNamed('/medication', arguments: notification.payload);
          break;
        case NotificationType.appointment:
          // Navigate to appointment details
          Navigator.of(context).pushNamed('/appointment', arguments: notification.payload);
          break;
        default:
          // Show a dialog with notification details
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(notification.title),
              content: Text(notification.body),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
      }
    }
  }
}
