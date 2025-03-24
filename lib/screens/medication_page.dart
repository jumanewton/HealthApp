// lib/screens/medication_page.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/medication.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../services/medication_service.dart';
import '../widgets/medication_card.dart';
import '../widgets/medication_card_shimmer.dart';

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({super.key});

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  final AuthService _authService = AuthService();
  final MedicationService _medicationService = MedicationService();
  final NotificationService _notificationService = NotificationService();
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _notificationService.init();
    _checkAuthState();
  }

  void _checkAuthState() {
    if (!_authService.isLoggedIn) {
      Future.microtask(() =>
          Navigator.pushReplacementNamed(context, '/login_register_page'));
    }
  }

  Future<void> _addOrEditMedication({
    String? id,
    String? name,
    String? dosage,
    String? schedule,
    TimeOfDay? reminderTime,
  }) async {
    final nameController = TextEditingController(text: name);
    final dosageController = TextEditingController(text: dosage);
    final scheduleController = TextEditingController(text: schedule);
    _selectedTime = reminderTime ?? TimeOfDay.now();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _buildMedicationDialog(
        context,
        id,
        nameController,
        dosageController,
        scheduleController,
      ),
    );

    if (saved == true) {
      final medication = Medication(
        id: id,
        name: nameController.text,
        dosage: dosageController.text,
        schedule: scheduleController.text,
        reminderTime: _selectedTime,
      );

      try {
        if (id == null) {
          final newId = await _medicationService.addMedication(medication);
          await _notificationService.scheduleNotification(
            id: newId.hashCode,
            title: 'Time to take ${medication.name}',
            body: 'Dosage: ${medication.dosage}, Schedule: ${medication.schedule}',
            time: medication.reminderTime,
          );
        } else {
          await _medicationService.updateMedication(medication);
          await _notificationService.scheduleNotification(
            id: id.hashCode,
            title: 'Time to take ${medication.name}',
            body: 'Dosage: ${medication.dosage}, Schedule: ${medication.schedule}',
            time: medication.reminderTime,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save medication: $e')),
        );
      }
    }
  }

  Widget _buildMedicationDialog(
    BuildContext context,
    String? id,
    TextEditingController nameController,
    TextEditingController dosageController,
    TextEditingController scheduleController,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(id == null ? 'Add Medication' : 'Edit Medication'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(labelText: 'Dosage'),
                ),
                TextField(
                  controller: scheduleController,
                  decoration: const InputDecoration(labelText: 'Schedule'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Reminder Time'),
                  subtitle: Text(_selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (pickedTime != null && pickedTime != _selectedTime) {
                      setState(() => _selectedTime = pickedTime);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Medication>>(
        stream: _medicationService.getMedications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return const MedicationCardShimmer();
                },
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No medications found.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _addOrEditMedication(),
                    child: const Text('Add Medication'),
                  ),
                ],
              ),
            );
          }

          final medications = snapshot.data!;
          return ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return MedicationCard(
                name: medication.name,
                dosage: medication.dosage,
                schedule: medication.schedule,
                reminderTime: medication.reminderTime.format(context),
                onEdit: () => _addOrEditMedication(
                  id: medication.id,
                  name: medication.name,
                  dosage: medication.dosage,
                  schedule: medication.schedule,
                  reminderTime: medication.reminderTime,
                ),
                onDelete: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Medication'),
                      content: const Text(
                          'Are you sure you want to delete this medication?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await _medicationService.deleteMedication(medication.id!);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditMedication(),
        child: const Icon(Icons.add),
      ),
    );
  }
}