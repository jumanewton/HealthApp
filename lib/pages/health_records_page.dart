import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/health_record.dart';
import '../services/health_record_service.dart';
import '../widgets/health_record_list_item.dart';
import '../widgets/add_health_record_dialog.dart';

class HealthRecordsPage extends StatefulWidget {
  const HealthRecordsPage({super.key});

  @override
  State<HealthRecordsPage> createState() => _HealthRecordsPageState();
}

class _HealthRecordsPageState extends State<HealthRecordsPage> {
  final HealthRecordService _recordService = HealthRecordService();

  // Function to open a health record URL
  Future<void> _openHealthRecord(BuildContext context, String url) async {
    final Uri recordUri = Uri.parse(url);
    if (await canLaunchUrl(recordUri)) {
      await launchUrl(recordUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  void _showAddRecordDialog([HealthRecord? recordToEdit]) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddHealthRecordDialog(
        recordToEdit: recordToEdit,
      ),
    ));
  }

  Future<void> _deleteRecord(String recordId) async {
    try {
      await _recordService.deleteHealthRecord(recordId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting record: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
      ),
      body: StreamBuilder<List<HealthRecord>>(
        stream: _recordService.getHealthRecords(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          // No data or empty data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No health records added yet',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddRecordDialog,
                    child: const Text('Add Health Record'),
                  ),
                ],
              ),
            );
          }
          
          // Data available
          final records = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              
              return HealthRecordListItem(
                record: record,
                onDelete: () => _deleteRecord(record.id),
                onEdit: () => _showAddRecordDialog(record),
                onOpen: () => _openHealthRecord(context, record.url),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}