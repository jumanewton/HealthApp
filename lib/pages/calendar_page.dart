import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart'; // For notification permissions
import 'package:app_settings/app_settings.dart'; // For opening app settings

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Calendar setup
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Events and reminders
  Map<DateTime, List<Map<String, String>>> events = {};

  // Dummy medications (replace with data from MedicationPage)
  final List<Map<String, String>> medications = [
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
  ];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Initialize time zones for notifications
    _initializeNotifications();
    _requestNotificationPermission(); // Request notification permissions
    _loadMedicationsIntoCalendar(); // Load medications into the calendar
  }

  // Initialize notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Request notification permissions (for Android 13+)
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print('Notification permission granted');
    } else {
      print('Notification permission denied');
      _openNotificationSettings(); // Open settings if denied
    }
  }

  // Open app settings using app_settings package
  Future<void> _openNotificationSettings() async {
    await AppSettings.openAppSettings(); // Opens the app settings page
  }

  // Load medications into the calendar
  void _loadMedicationsIntoCalendar() {
    for (var medication in medications) {
      final schedule = medication['schedule'];
      if (schedule != null) {
        final eventDate = _focusedDay; // Use the current day for simplicity
        final event = {
          'title': 'Take ${medication['name']} (${medication['dosage']})',
          'description': schedule,
        };

        if (events[eventDate] == null) {
          events[eventDate] = [event];
        } else {
          events[eventDate]!.add(event);
        }
      }
    }
  }

  // Function to add a custom reminder
  void _addReminder() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController titleController = TextEditingController();
        final TextEditingController descriptionController =
            TextEditingController();
        DateTime? selectedDate;

        return AlertDialog(
          title: const Text('Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Doctor Appointment',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., Checkup at 3:00 PM',
                ),
              ),
              TextButton(
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _focusedDay,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                  }
                },
                child: const Text('Select Date'),
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
                if (selectedDate != null &&
                    titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  setState(() {
                    final event = {
                      'title': titleController.text,
                      'description': descriptionController.text,
                    };

                    if (events[selectedDate!] == null) {
                      events[selectedDate!] = [event];
                    } else {
                      events[selectedDate!]!.add(event);
                    }

                    // Schedule a notification
                    _scheduleNotification(
                      title: titleController.text,
                      body: descriptionController.text,
                      scheduledDate: selectedDate!,
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Function to schedule a notification
  void _scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      print('Scheduled date is in the past. Notification not scheduled.');
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Channel ID
      'your_channel_name', // Channel Name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID (must be unique)
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local), // Convert to local time zone
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Ensure notification triggers in Doze mode
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) => events[day] ?? [],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: _selectedDay != null && events[_selectedDay] != null
                  ? events[_selectedDay]!
                      .map((event) => Card(
                            child: ListTile(
                              title: Text(event['title']!),
                              subtitle: Text(event['description']!),
                            ),
                          ))
                      .toList()
                  : [const Center(child: Text('No events for this day'))],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        child: const Icon(Icons.add),
      ),
    );
  }
}