import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_calendar/device_calendar.dart';
import '../models/calendar_event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final DeviceCalendarPlugin _deviceCalendar = DeviceCalendarPlugin();

  // Channel IDs
  static const String healthMateChannelId = 'health_mate_channel';
  static const String medicationChannelId = 'medication_reminder';

  Future<void> init() async {
    tz.initializeTimeZones();

    // Initialize notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification taps
        print('Notification tapped: ${response.payload}');
      },
    );

    // Request all required permissions
    await _requestPermissions();

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  Future<void> _requestPermissions() async {
    // Request notification permissions
    final notificationStatus = await Permission.notification.request();
    if (!notificationStatus.isGranted) {
      print('Notification permission denied');
    }

    // Request exact alarm permission for Android 12+
    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
      if (status.isDenied) {
        print('Exact alarm permission denied');
      } else {
        print('Exact alarm permission granted');
      }
    }

    // Request calendar permissions
    final calendarPermission = await _deviceCalendar.requestPermissions();
    if (calendarPermission.data != null && !calendarPermission.data!) {
      print('Calendar permission denied');
    }
  }

  Future<void> _createNotificationChannels() async {
    // Health Mate channel
    const AndroidNotificationChannel healthMateChannel =
        AndroidNotificationChannel(
      healthMateChannelId,
      'HealthMate Notifications',
      importance: Importance.high,
      description: 'Notifications for medications and appointments',
    );

    // Medication reminder channel
    const AndroidNotificationChannel medicationChannel =
        AndroidNotificationChannel(
      medicationChannelId,
      'Medication Reminder',
      importance: Importance.high,
      description: 'Reminders for taking medications',
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(healthMateChannel);
      await androidPlugin.createNotificationChannel(medicationChannel);
    }
  }

  // Schedule a notification for a specific time of day
  Future<void> scheduleTimeNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
    bool daily = true,
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

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          medicationChannelId,
          'Medication Reminder',
          channelDescription: 'Reminders for taking medications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: daily ? DateTimeComponents.time : null,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Schedule a notification for a calendar event
  Future<void> scheduleEventNotification(CalendarEvent event) async {
  // Don't schedule if the time is in the past
  if (event.dateTime.isBefore(DateTime.now())) {
    return;
  }

  // Check if we can schedule exact alarms
  bool canScheduleExact = await Permission.scheduleExactAlarm.isGranted;

    // Set icon based on event category
    String icon;
    switch (event.category) {
      case EventCategory.medication:
        icon = 'ic_medication';
        break;
      case EventCategory.appointment:
        icon = 'ic_appointment';
        break;
      case EventCategory.reminder:
      default:
        icon = 'ic_reminder';
        break;
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      healthMateChannelId,
      'HealthMate Notifications',
      channelDescription: 'Notifications for medications and appointments',
      importance: Importance.high,
      priority: Priority.high,
      icon: icon,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      // First try with the user's preferred setting
      AndroidScheduleMode scheduleMode = canScheduleExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
          
      await _notifications.zonedSchedule(
        event.notificationId,
        event.title,
        event.description,
        tz.TZDateTime.from(event.dateTime, tz.local),
        notificationDetails,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: event.id,
      );

      // For recurring events, schedule the next occurrence
      if (event.recurrence != RecurrencePattern.once) {
        _scheduleRecurringNotifications(event);
      }
    } catch (e) {
      print('Error scheduling notification: $e');
      
      // If the error is related to exact alarms, try with inexact instead
      if (canScheduleExact) {
        try {
          await _notifications.zonedSchedule(
            event.notificationId,
            event.title,
            event.description,
            tz.TZDateTime.from(event.dateTime, tz.local),
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: event.id,
          );
          
          print('Fallback to inexact notification scheduled successfully');
        } catch (fallbackError) {
          print('Even fallback notification failed: $fallbackError');
        }
      }
    }
  }

  void _scheduleRecurringNotifications(CalendarEvent event) {
    // This is a simple implementation; a production app would use a WorkManager
    // or background service to handle recurring notifications more efficiently
    final DateTime nextOccurrence = event.getNextOccurrence();

    if (nextOccurrence.isAfter(DateTime.now())) {
      final CalendarEvent nextEvent = event.copyWith(
        dateTime: nextOccurrence,
        notificationId: event.notificationId + 1,
      );

      scheduleEventNotification(nextEvent);
    }
  }

  // Cancel a notification
  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  // Add event to device calendar
  Future<String?> addToDeviceCalendar(CalendarEvent event) async {
    try {
      // Get default calendar
      final calendarsResult = await _deviceCalendar.retrieveCalendars();
      final calendars = calendarsResult.data;

      if (calendars == null || calendars.isEmpty) {
        return 'No calendars found';
      }

      // Use first available calendar
      final String calendarId = calendars.first.id!;

      // Get event time and convert to TZDateTime
      final DateTime eventTime = event.dateTime;
      final tz.TZDateTime tzStartTime = tz.TZDateTime.from(eventTime, tz.local);
      final tz.TZDateTime tzEndTime =
          tz.TZDateTime.from(eventTime.add(const Duration(hours: 1)), tz.local);

      final Event deviceEvent = Event(
        calendarId,
        title: event.title,
        description: event.description,
        start: tzStartTime,
        end: tzEndTime,
      );

      // Set recurrence rule if recurring
      if (event.recurrence != RecurrencePattern.once) {
        String rule;
        switch (event.recurrence) {
          case RecurrencePattern.daily:
            rule = 'FREQ=DAILY';
            break;
          case RecurrencePattern.weekly:
            rule = 'FREQ=WEEKLY';
            break;
          case RecurrencePattern.monthly:
            rule = 'FREQ=MONTHLY';
            break;
          default:
            rule = '';
        }

        if (rule.isNotEmpty) {
          deviceEvent.recurrenceRule = RecurrenceRule(
            RecurrenceFrequency.values[event.recurrence.index],
            endDate: tz.TZDateTime.from(
                eventTime.add(const Duration(days: 365)), tz.local),
          );
        }
      }

      // Create the event
      final createResult =
          await _deviceCalendar.createOrUpdateEvent(deviceEvent);
      return createResult?.data;
    } catch (e) {
      print('Error adding to device calendar: $e');
      return 'Failed to add to calendar: $e';
    }
  }

  Future<void> configureSelectNotificationHandler(
    void Function(NotificationResponse) onNotificationResponse
  ) async {
    // Store the callback handler for notification taps
    final InitializationSettings initializationSettings = InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationResponse,
    );
  }

  // Add this method for showing a simple notification immediately
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = healthMateChannelId,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'HealthMate Notifications',
          channelDescription: 'Notifications for medications and appointments',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
  }
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = healthMateChannelId,
  }) async {
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'HealthMate Notifications',
          channelDescription: 'Notifications for medications and appointments',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  }
