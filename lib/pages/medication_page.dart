import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_auth/firebase_auth.dart';

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _notificationService.init();
    _checkAuthState();
  }

  // Check if user is logged in
  void _checkAuthState() {
    if (_auth.currentUser == null) {
      // Navigate to login page if not logged in
      Future.microtask(() => 
        Navigator.pushReplacementNamed(context, '/login_register_page')
      );
    }
  }

  // Get current user ID from Firebase Auth
  String get _userId {
    final User? user = _auth.currentUser;
    if (user == null) {
      // This shouldn't normally be reached due to _checkAuthState
      // but keeping as a fallback
      return 'demo_user';
    }
    return user.uid;
  }

  Stream<QuerySnapshot> getMedications() {
    return _firestore.collection('users/$_userId/medications').snapshots();
  }

  Future<void> _addOrEditMedication({
    String? id,
    String? name,
    String? dosage,
    String? schedule,
    TimeOfDay? reminderTime,
  }) async {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController dosageController = TextEditingController(text: dosage);
    TextEditingController scheduleController = TextEditingController(text: schedule);
    
    _selectedTime = reminderTime ?? TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) {
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
                      subtitle: Text(_selectedTime!.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime!,
                        );
                        if (pickedTime != null && pickedTime != _selectedTime) {
                          setState(() {
                            _selectedTime = pickedTime;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final medicationData = {
                      'name': nameController.text,
                      'dosage': dosageController.text,
                      'schedule': scheduleController.text,
                      'reminderTime': {
                        'hour': _selectedTime!.hour,
                        'minute': _selectedTime!.minute,
                      },
                    };

                    if (id == null) {
                      // Add new medication
                      final docRef = await _firestore
                          .collection('users/$_userId/medications')
                          .add(medicationData);
                      await _scheduleNotification(docRef.id, medicationData);
                    } else {
                      // Update existing medication
                      await _firestore
                          .collection('users/$_userId/medications')
                          .doc(id)
                          .update(medicationData);
                      await _scheduleNotification(id, medicationData);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _scheduleNotification(String id, Map<String, dynamic> medicationData) async {
    final timeMap = medicationData['reminderTime'] as Map<String, dynamic>;
    final reminderTime = TimeOfDay(hour: timeMap['hour'], minute: timeMap['minute']);
    
    await _notificationService.scheduleNotification(
      id: id.hashCode,
      title: 'Time to take ${medicationData['name']}',
      body: 'Dosage: ${medicationData['dosage']}, Schedule: ${medicationData['schedule']}',
      time: reminderTime,
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
              // Implement search functionality
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getMedications(),
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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              // Handle different data formats for backward compatibility
              TimeOfDay? reminderTime;
              if (data['reminderTime'] is Map) {
                final timeMap = data['reminderTime'] as Map<String, dynamic>;
                reminderTime = TimeOfDay(
                  hour: timeMap['hour'],
                  minute: timeMap['minute'],
                );
              } else if (data['reminderTime'] is String) {
                // Parse from string format if stored that way
                final parts = data['reminderTime'].toString().split(':');
                if (parts.length == 2) {
                  reminderTime = TimeOfDay(
                    hour: int.parse(parts[0]),
                    minute: int.parse(parts[1].split(' ')[0]),
                  );
                }
              }

              return MedicationCard(
                name: data['name'] ?? 'Unknown',
                dosage: data['dosage'] ?? '',
                schedule: data['schedule'] ?? '',
                reminderTime: reminderTime != null ? reminderTime.format(context) : 'No reminder',
                onEdit: () => _addOrEditMedication(
                  id: doc.id,
                  name: data['name'],
                  dosage: data['dosage'],
                  schedule: data['schedule'],
                  reminderTime: reminderTime,
                ),
                onDelete: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Medication'),
                      content: const Text('Are you sure you want to delete this medication?'),
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
                    await _firestore
                        .collection('users/$_userId/medications')
                        .doc(doc.id)
                        .delete();
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

class MedicationCardShimmer extends StatelessWidget {
  const MedicationCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  // Subtitle placeholder 1
                  Container(
                    width: 200,
                    height: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  // Subtitle placeholder 2
                  Container(
                    width: 150,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            // Action button placeholder
            Container(
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminder',
          'Medication Reminder',
          channelDescription: 'Reminders for taking medications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      // Removed androidAllowWhileIdle which is deprecated
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}