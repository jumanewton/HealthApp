import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = Color(event.category.color);
    
    // Format time to display
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('E, MMM d');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: categoryColor.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Category Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(event.category),
                    color: categoryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event.category.name,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: categoryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (event.recurrence != RecurrencePattern.once)
                    Chip(
                      label: Text(
                        event.recurrence.name,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: categoryColor,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ),
            
            // Event Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: event.isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                        ),
                      ),
                      if (onComplete != null)
                        IconButton(
                          icon: Icon(
                            event.isCompleted 
                                ? Icons.check_circle 
                                : Icons.circle_outlined,
                            color: event.isCompleted 
                                ? Colors.green 
                                : Colors.grey,
                          ),
                          onPressed: onComplete,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          iconSize: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeFormat.format(event.dateTime),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(event.dateTime),
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.red,
                          onPressed: onDelete,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Additional info for specific event types
            if (event is MedicationEvent)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.medication,
                      size: 16,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dosage: ${(event as MedicationEvent).dosage}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.medication:
        return Icons.medication;
      case EventCategory.appointment:
        return Icons.event;
      case EventCategory.reminder:
        return Icons.notifications;
    }
  }
}