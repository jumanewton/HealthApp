import 'package:flutter/material.dart';

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  // Dummy data for medications (replace with Firebase data)
  List<Map<String, String>> medications = [
    {
      'name': 'Paracetamol',
      'dosage': '500 mg',
      'schedule': 'Every 6 hours',
    },
    {
      'name': 'Amoxicillin',
      'dosage': '250 mg',
      'schedule': 'Twice a day',
    },
    {
      'name': 'Vitamin C',
      'dosage': '1000 mg',
      'schedule': 'Once a day',
    },
  ];

  // Function to add a new medication
  void _addMedication() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController nameController = TextEditingController();
        final TextEditingController dosageController = TextEditingController();
        final TextEditingController scheduleController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Medication'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  hintText: 'e.g., Paracetamol',
                ),
              ),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g., 500 mg',
                ),
              ),
              TextField(
                controller: scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Schedule',
                  hintText: 'e.g., Every 6 hours',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  medications.add({
                    'name': nameController.text,
                    'dosage': dosageController.text,
                    'schedule': scheduleController.text,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Function to edit a medication
  void _editMedication(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController nameController =
            TextEditingController(text: medications[index]['name']);
        final TextEditingController dosageController =
            TextEditingController(text: medications[index]['dosage']);
        final TextEditingController scheduleController =
            TextEditingController(text: medications[index]['schedule']);

        return AlertDialog(
          title: const Text('Edit Medication'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                ),
              ),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                ),
              ),
              TextField(
                controller: scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Schedule',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  medications[index] = {
                    'name': nameController.text,
                    'dosage': dosageController.text,
                    'schedule': scheduleController.text,
                  };
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a medication
  void _deleteMedication(int index) {
    setState(() {
      medications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final medication = medications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              leading: const Icon(Icons.medical_services, size: 40),
              title: Text(medication['name']!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dosage: ${medication['dosage']}'),
                  Text('Schedule: ${medication['schedule']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editMedication(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteMedication(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedication,
        child: const Icon(Icons.add),
      ),
    );
  }
}