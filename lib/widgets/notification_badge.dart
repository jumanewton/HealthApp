import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color badgeColor;
  final double badgeSize;
  
  const NotificationBadge({
    super.key,
    required this.child,
    required this.onTap,
    this.badgeColor = Colors.red,
    this.badgeSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            InkWell(
              onTap: onTap,
              child: child,
            ),
            if (provider.unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: badgeSize,
                    minHeight: badgeSize,
                  ),
                  child: Center(
                    child: Text(
                      provider.unreadCount < 100 
                          ? provider.unreadCount.toString() 
                          : '99+',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}