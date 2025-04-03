import 'package:flutter/material.dart';
import 'package:healthmate/services/notification_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../services/calendar_repository.dart';
import '../widgets/event_card.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Calendar settings
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Event maps
  Map<String, List<CalendarEvent>> _events = {};

  // Services
  late CalendarRepository _calendarRepository;
  late NotificationService _notificationService;

  // Controllers
  final _searchController = TextEditingController();
  bool _showSearch = false;
  List<CalendarEvent> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _calendarRepository = CalendarRepository();
    _notificationService = NotificationService();
    _notificationService.init();

    _selectedDay = _focusedDay;
    _loadEvents();
  }

  // Load all events from repository
  Future<void> _loadEvents() async {
    _calendarRepository.streamEvents().listen((eventsList) {
      setState(() {
        // Group events by date
        _events = {};
        for (var event in eventsList) {
          final dateKey = _getDateKey(event.dateTime);
          if (_events[dateKey] == null) {
            _events[dateKey] = [];
          }
          _events[dateKey]!.add(event);
        }
      });
    });
  }

  // Get formatted date key for events map
  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Add a new event
  void _addEvent() async {
    final EventCategory? selectedCategory = await showDialog<EventCategory>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Event Type'),
        children: EventCategory.values.map((category) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, category),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(category),
                  color: Color(category.color),
                ),
                const SizedBox(width: 16),
                Text(category.name),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (selectedCategory == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EventForm(
        selectedDay: _selectedDay ?? DateTime.now(),
        category: selectedCategory,
        onSave: _saveEvent,
      ),
    );
  }

  // Save a new event
  Future<void> _saveEvent(CalendarEvent event) async {
    try {
      // Save to repository
      await _calendarRepository.addEvent(event);

      // Schedule notification
      await _notificationService.scheduleEventNotification(event);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${event.category.name} added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Update an existing event
  Future<void> _updateEvent(CalendarEvent event,
      {bool toggleComplete = false}) async {
    try {
      CalendarEvent updatedEvent = event;

      if (toggleComplete) {
        updatedEvent = event.copyWith(isCompleted: !event.isCompleted);
      }

      // Save to repository
      await _calendarRepository.updateEvent(updatedEvent);

      // If completion status changed, update notification
      if (toggleComplete) {
        if (updatedEvent.isCompleted) {
          await _notificationService
              .cancelNotification(updatedEvent.notificationId);
        } else {
          await _notificationService.scheduleEventNotification(updatedEvent);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Delete an event
  Future<void> _deleteEvent(CalendarEvent event) async {
    try {
      // Confirm deletion
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${event.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('DELETE'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Delete from repository
      await _calendarRepository.deleteEvent(event.id);

      // Cancel notification
      await _notificationService.cancelNotification(event.notificationId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Export event to device calendar
  Future<void> _exportToDeviceCalendar(CalendarEvent event) async {
    try {
      final result = await _notificationService.addToDeviceCalendar(event);
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event added to device calendar')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting to calendar: $e')),
      );
    }
  }

  // Search events
  Future<void> _searchEvents(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final results = await _calendarRepository.searchEvents(query);
    setState(() {
      _searchResults = results;
    });
  }

  // View event details
  void _viewEventDetails(CalendarEvent event) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                event.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(event.description),
              leading: Icon(
                _getCategoryIcon(event.category),
                color: Color(event.category.color),
                size: 32,
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Date & Time'),
              subtitle: Text(
                DateFormat('EEEE, MMMM d, yyyy • h:mm a')
                    .format(event.dateTime),
              ),
              leading: const Icon(Icons.access_time),
            ),
            ListTile(
              title: const Text('Recurrence'),
              subtitle: Text(event.recurrence.name),
              leading: const Icon(Icons.repeat),
            ),
            if (event is MedicationEvent)
              ListTile(
                title: const Text('Dosage'),
                subtitle: Text((event as MedicationEvent).dosage),
                leading: const Icon(Icons.medication_outlined),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  onPressed: () {
                    Navigator.pop(context);
                    // Show edit form
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => _EventForm(
                        selectedDay: event.dateTime,
                        category: event.category,
                        existingEvent: event,
                        onSave: _saveEvent,
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Export'),
                  onPressed: () {
                    Navigator.pop(context);
                    _exportToDeviceCalendar(event);
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteEvent(event);
                  },
                ),
              ],
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

  // Get events for selected day
  List<CalendarEvent> _getEventsForDay(DateTime day) {
    final dateKey = _getDateKey(day);
    return _events[dateKey]?.cast<CalendarEvent>() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final dayEvents =
        _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search events...',
                  border: InputBorder.none,
                ),
                onChanged: _searchEvents,
                autofocus: true,
              )
            : const Text('Calendar'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _searchResults.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            eventLoader: (day) {
              return _getEventsForDay(day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _showSearch = false;
                _searchController.clear();
                _searchResults.clear();
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
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonDecoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(16),
              ),
              formatButtonTextStyle: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: _showSearch && _searchController.text.isNotEmpty
                ? _buildSearchResults()
                : _buildEventsList(dayEvents as List<CalendarEvent>),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventsList(List<CalendarEvent> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No events for this day',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add one',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Sort events by time
    final sortedEvents = List<CalendarEvent>.from(events)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedEvents.length,
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        return EventCard(
          event: event,
          onTap: () => _viewEventDetails(event),
          onComplete: () => _updateEvent(event, toggleComplete: true),
          onDelete: () => _deleteEvent(event),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No matching events found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Sort events by date
    final sortedResults = List<CalendarEvent>.from(_searchResults)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedResults.length,
      itemBuilder: (context, index) {
        final event = sortedResults[index];
        return EventCard(
          event: event,
          onTap: () => _viewEventDetails(event),
          onComplete: () => _updateEvent(event, toggleComplete: true),
          onDelete: () => _deleteEvent(event),
        );
      },
    );
  }
}

// Event Form Widget
class _EventForm extends StatefulWidget {
  final DateTime selectedDay;
  final EventCategory category;
  final CalendarEvent? existingEvent;
  final Function(CalendarEvent) onSave;

  const _EventForm({
    Key? key,
    required this.selectedDay,
    required this.category,
    this.existingEvent,
    required this.onSave,
  }) : super(key: key);

  @override
  State<_EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<_EventForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dosageController;
  late DateTime _selectedDateTime;
  late RecurrencePattern _recurrence;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();

    // Initialize with existing event values or defaults
    final event = widget.existingEvent;

    _titleController = TextEditingController(
      text: event?.title ?? '',
    );

    _descriptionController = TextEditingController(
      text: event?.description ?? '',
    );

    _dosageController = TextEditingController(
      text: event is MedicationEvent ? (event).dosage : '',
    );

    _selectedDateTime = event?.dateTime ?? widget.selectedDay;
    _selectedTime = TimeOfDay.fromDateTime(_selectedDateTime);
    _recurrence = event?.recurrence ?? RecurrencePattern.once;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;

        // Update the datetime with the new time
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        // Preserve the time from the existing selection
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  void _saveEvent() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (widget.category == EventCategory.medication &&
        _dosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter dosage information')),
      );
      return;
    }

    // Create the appropriate event type
    CalendarEvent event;

    if (widget.category == EventCategory.medication) {
      event = MedicationEvent(
        id: widget.existingEvent?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        dateTime: _selectedDateTime,
        dosage: _dosageController.text,
        medicationId: widget.existingEvent is MedicationEvent
            ? (widget.existingEvent as MedicationEvent).medicationId
            : DateTime.now().millisecondsSinceEpoch.toString(),
        recurrence: _recurrence,
        notificationId: widget.existingEvent?.notificationId,
      );
    } else {
      event = CalendarEvent(
        id: widget.existingEvent?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        dateTime: _selectedDateTime,
        category: widget.category,
        recurrence: _recurrence,
        notificationId: widget.existingEvent?.notificationId,
      );
    }

    widget.onSave(event);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.existingEvent != null
                ? 'Edit Event'
                : 'Add ${widget.category.name}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          if (widget.category == EventCategory.medication) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage',
                border: OutlineInputBorder(),
                hintText: 'e.g., 500mg twice daily',
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      DateFormat('EEE, MMM d, yyyy').format(_selectedDateTime),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: _selectTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedTime.format(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<RecurrencePattern>(
            decoration: const InputDecoration(
              labelText: 'Recurrence',
              border: OutlineInputBorder(),
            ),
            value: _recurrence,
            items: RecurrencePattern.values.map((pattern) {
              return DropdownMenuItem<RecurrencePattern>(
                value: pattern,
                child: Text(pattern.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _recurrence = value;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text(widget.existingEvent != null ? 'UPDATE' : 'SAVE'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
