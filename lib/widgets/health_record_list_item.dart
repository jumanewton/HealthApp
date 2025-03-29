import 'package:flutter/material.dart';
import '../models/health_record.dart';

class HealthRecordListItem extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const HealthRecordListItem({
    super.key,
    required this.record,
    required this.onOpen,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: Icon(
          record.type.toLowerCase().contains('lab') ? Icons.science :
          record.type.toLowerCase().contains('imag') ? Icons.image :
          Icons.medical_services,
          size: 40,
        ),
        title: Text(record.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.type),
            const SizedBox(height: 4),
            Text(
              record.date,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye),
              onPressed: onOpen,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Record'),
                    content: const Text('Are you sure you want to delete this record?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onDelete();
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        onTap: onOpen,
      ),
    );
  }
}