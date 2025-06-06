import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/medication.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../services/medication_service.dart';
import '../widgets/medication_card.dart';
import '../widgets/medication_card_shimmer.dart';
import '../widgets/filter_status_bar.dart';

enum MedicationFilter {
  all,
  morning,
  afternoon,
  evening,
  daily,
  recentlyAdded
}

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({super.key});

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  MedicationFilter _currentFilter = MedicationFilter.all;
  final AuthService _authService = AuthService();
  final MedicationService _medicationService = MedicationService();
  final NotificationService _notificationService = NotificationService();
  late TimeOfDay _selectedTime;

  // Search functionality variables
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _notificationService.init();
    _checkAuthState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _checkAuthState() {
    if (!_authService.isLoggedIn) {
      Future.microtask(() =>
          Navigator.pushReplacementNamed(context, '/login_register_page'));
    }
  }

  void _toggleSearch() {
    setState(() {
      if (_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
      _isSearching = !_isSearching;
    });
  }

  // Filter medications based on selected filter
  List<Medication> _applyFilters(List<Medication> medications) {
    if (_currentFilter == MedicationFilter.all) {
      return medications;
    }
    
    final now = DateTime.now();
    
    return medications.where((med) {
      switch (_currentFilter) {
        case MedicationFilter.morning:
          final time = med.reminderTime;
          return time.hour >= 5 && time.hour < 12;
        case MedicationFilter.afternoon:
          final time = med.reminderTime;
          return time.hour >= 12 && time.hour < 17;
        case MedicationFilter.evening:
          final time = med.reminderTime;
          return time.hour >= 17 || time.hour < 5;
        case MedicationFilter.daily:
          return med.schedule.toLowerCase().contains('daily') || 
                med.schedule.toLowerCase().contains('every day');
        case MedicationFilter.recentlyAdded:
          if (med.dateAdded != null) {
            return now.difference(med.dateAdded!).inDays <= 7;
          }
          return false;
        default:
          return true;
      }
    }).toList();
  }

  // Show filter dialog method
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Medications'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterOption(MedicationFilter.all, 'All Medications', setState),
                  _buildFilterOption(MedicationFilter.morning, 'Morning (5AM-12PM)', setState),
                  _buildFilterOption(MedicationFilter.afternoon, 'Afternoon (12PM-5PM)', setState),
                  _buildFilterOption(MedicationFilter.evening, 'Evening (5PM-5AM)', setState),
                  _buildFilterOption(MedicationFilter.daily, 'Daily Medications', setState),
                  _buildFilterOption(MedicationFilter.recentlyAdded, 'Recently Added', setState),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper method to build filter options
  Widget _buildFilterOption(MedicationFilter filter, String label, StateSetter setState) {
    return RadioListTile<MedicationFilter>(
      title: Text(label),
      value: filter,
      groupValue: _currentFilter,
      onChanged: (value) {
        setState(() {
          _currentFilter = value!;
        });
        this.setState(() {});
        Navigator.of(context).pop();
      },
    );
  }

  // Helper method to get a user-friendly filter name
  String _getFilterDisplayName(MedicationFilter filter) {
    switch (filter) {
      case MedicationFilter.morning:
        return 'Morning Medications';
      case MedicationFilter.afternoon:
        return 'Afternoon Medications';
      case MedicationFilter.evening:
        return 'Evening Medications';
      case MedicationFilter.daily:
        return 'Daily Medications';
      case MedicationFilter.recentlyAdded:
        return 'Recently Added';
      default:
        return 'All Medications';
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
          await _notificationService.scheduleTimeNotification(
            id: newId.hashCode,
            title: 'Time to take ${medication.name}',
            body: 'Dosage: ${medication.dosage}, Schedule: ${medication.schedule}',
            time: medication.reminderTime,
            payload: newId,
            daily: true,
          );
        } else {
          await _medicationService.updateMedication(medication);
          await _notificationService.cancelNotification(id.hashCode);
          await _notificationService.scheduleTimeNotification(
            id: id.hashCode,
            title: 'Time to take ${medication.name}',
            body: 'Dosage: ${medication.dosage}, Schedule: ${medication.schedule}',
            time: medication.reminderTime,
            payload: id,
            daily: true,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Medication ${id == null ? 'added' : 'updated'} successfully'),
          ),
        );
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

  // Filter medications based on search query
  List<Medication> _filterMedications(List<Medication> medications) {
    if (_searchQuery.isEmpty) {
      return medications;
    }

    return medications.where((med) {
      return med.name.toLowerCase().contains(_searchQuery) ||
          med.dosage.toLowerCase().contains(_searchQuery) ||
          med.schedule.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search medications...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color),
                )
            : const Text('Medications'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Show filter status bar if a filter is active
          if (_currentFilter != MedicationFilter.all)
            FilterStatusBar(
              filterName: _getFilterDisplayName(_currentFilter),
              onClear: () {
                setState(() {
                  _currentFilter = MedicationFilter.all;
                });
              },
            ),
          
          // The StreamBuilder with Expanded to take remaining space
          Expanded(
            child: StreamBuilder<List<Medication>>(
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

                // Apply filters
                final allMedications = snapshot.data!;
                final searchFiltered = _filterMedications(allMedications);
                final medications = _applyFilters(searchFiltered);

                if (medications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No medications match your search.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _currentFilter = MedicationFilter.all;
                            });
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

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
                          await _notificationService
                              .cancelNotification(medication.id!.hashCode);
                          await _medicationService.deleteMedication(medication.id!);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Medication deleted successfully')),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditMedication(),
        child: const Icon(Icons.add),
      ),
    );
  }
}