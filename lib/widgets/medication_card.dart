// lib/widgets/medication_card.dart
import 'package:flutter/material.dart';

class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String schedule;
  final String reminderTime;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.reminderTime,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: ListTile(
        leading: _getMedicationIcon(name),
        title: Text(
          name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dosage: $dosage'),
            Text('Schedule: $schedule'),
            Text('Reminder: $reminderTime'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Icon _getMedicationIcon(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('vitamin')) {
      return const Icon(Icons.spa, color: Colors.green);
    } else if (nameLower.contains('amoxicillin') || nameLower.contains('antibiotic')) {
      return const Icon(Icons.medical_services, color: Colors.blue);
    } else {
      return const Icon(Icons.medication, color: Colors.red);
    }
  }
}