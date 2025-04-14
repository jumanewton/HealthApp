import 'package:flutter/material.dart';
import '../models/health_record.dart';
import 'package:intl/intl.dart';

class HealthRecordListItem extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onOpen;
  final VoidCallback onSummarize; // New callback for summarization

  const HealthRecordListItem({
    super.key,
    required this.record,
    required this.onDelete,
    required this.onEdit,
    required this.onOpen,
    required this.onSummarize, // Add this parameter
  });

  // Get icon based on record type
  IconData _getIconForRecordType(RecordType type) {
    switch (type) {
      case RecordType.labReport:
        return Icons.science;
      case RecordType.imagingReport:
        return Icons.image;
      case RecordType.prescription:
        return Icons.medical_services;
      case RecordType.medicalNotes:
        return Icons.note;
      case RecordType.vaccination:
        return Icons.vaccines;
      case RecordType.medicalDocument:
        return Icons.description;
      case RecordType.other:
      default:
        return Icons.folder;
    }
  }

  // Get readable record type name
  String _getRecordTypeName(RecordType type) {
    switch (type) {
      case RecordType.labReport:
        return 'Lab Report';
      case RecordType.imagingReport:
        return 'Imaging Report';
      case RecordType.prescription:
        return 'Prescription';
      case RecordType.medicalNotes:
        return 'Medical Notes';
      case RecordType.vaccination:
        return 'Vaccination Record';
      case RecordType.medicalDocument:
        return 'Medical Document';
      case RecordType.other:
      default:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        children: [
          // Record details
          ListTile(
            leading: Icon(_getIconForRecordType(record.type)),
            title: Text(
              record.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getRecordTypeName(record.type)),
                Text('Added on ${dateFormat.format(record.dateAdded)}'),
              ],
            ),
            onTap: onOpen,
          ),
          
          // Summary section if available
          if (record.summary != null && record.summary!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const Text(
                    'AI Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.summary!,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextButton(
                    onPressed: onSummarize,
                    child: const Text('View Full Summary'),
                  ),
                ],
              ),
            ),
            
          // Action buttons
          ButtonBar(
            alignment: MainAxisAlignment.end,
            children: [
              // Summarize button
              if (record.summary == null || record.summary!.isEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.summarize),
                  label: const Text('Summarize'),
                  onPressed: onSummarize,
                ),
              TextButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                onPressed: onEdit,
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Record'),
                      content: const Text(
                        'Are you sure you want to delete this health record? This action cannot be undone.'
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                          child: const Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}