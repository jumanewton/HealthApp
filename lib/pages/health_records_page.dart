import 'package:flutter/material.dart';
import 'package:healthmate/screens/document_summary_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/health_record.dart';
import '../services/health_record_service.dart';
import '../widgets/health_record_list_item.dart';
import '../widgets/add_health_record_dialog.dart';
import '../widgets/filter_status_bar.dart';

enum RecordFilter {
  all,
  labResults,
  prescriptions,
  appointments,
  imaging,
  lastMonth,
  lastThreeMonths,
  hasSummary,
  noSummary
}

class HealthRecordsPage extends StatefulWidget {
  const HealthRecordsPage({super.key});

  @override
  State<HealthRecordsPage> createState() => _HealthRecordsPageState();
}

class _HealthRecordsPageState extends State<HealthRecordsPage> {
  final HealthRecordService _recordService = HealthRecordService();
  RecordFilter _currentFilter = RecordFilter.all;
  
  // Search functionality variables
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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

  void _toggleSearch() {
    setState(() {
      if (_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
      _isSearching = !_isSearching;
    });
  }
  
  // Helper method to get a user-friendly filter name
  String _getFilterDisplayName(RecordFilter filter) {
    switch (filter) {
      case RecordFilter.labResults:
        return 'Lab Results';
      case RecordFilter.prescriptions:
        return 'Prescriptions';
      case RecordFilter.appointments:
        return 'Appointments';
      case RecordFilter.imaging:
        return 'Imaging';
      case RecordFilter.lastMonth:
        return 'Last Month';
      case RecordFilter.lastThreeMonths:
        return 'Last 3 Months';
      case RecordFilter.hasSummary:
        return 'Has Summary';
      case RecordFilter.noSummary:
        return 'No Summary';
      default:
        return 'All Records';
    }
  }

  // Filter health records based on search query
  List<HealthRecord> _filterHealthRecords(List<HealthRecord> records) {
    if (_searchQuery.isEmpty) {
      return records;
    }

    return records.where((record) {
      return record.title.toLowerCase().contains(_searchQuery) ||
            (record.summary?.toLowerCase() ?? '').contains(_searchQuery) ||
            record.type.toString().toLowerCase().contains(_searchQuery) ||
            record.dateAdded.toString().contains(_searchQuery);
    }).toList();
  }

  List<HealthRecord> _applyFilters(List<HealthRecord> records) {
    if (_currentFilter == RecordFilter.all) {
      return records;
    }
    
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
    
    return records.where((record) {
      switch (_currentFilter) {
        case RecordFilter.labResults:
          return record.type == RecordType.labResult;
        case RecordFilter.prescriptions:
          return record.type == RecordType.prescription;
        case RecordFilter.appointments:
          return record.type == RecordType.appointment;
        case RecordFilter.imaging:
          return record.type == RecordType.imaging;
        case RecordFilter.lastMonth:
          return record.dateAdded.isAfter(oneMonthAgo);
        case RecordFilter.lastThreeMonths:
          return record.dateAdded.isAfter(threeMonthsAgo);
        case RecordFilter.hasSummary:
          return record.summary != null && record.summary!.isNotEmpty;
        case RecordFilter.noSummary:
          return record.summary == null || record.summary!.isEmpty;
        default:
          return true;
      }
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Health Records'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterOption(RecordFilter.all, 'All Records', setState),
                  const Divider(),
                  const Text('By Type', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildFilterOption(RecordFilter.labResults, 'Lab Results', setState),
                  _buildFilterOption(RecordFilter.prescriptions, 'Prescriptions', setState),
                  _buildFilterOption(RecordFilter.appointments, 'Appointments', setState),
                  _buildFilterOption(RecordFilter.imaging, 'Imaging', setState),
                  const Divider(),
                  const Text('By Date', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildFilterOption(RecordFilter.lastMonth, 'Last Month', setState),
                  _buildFilterOption(RecordFilter.lastThreeMonths, 'Last 3 Months', setState),
                  const Divider(),
                  const Text('By Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildFilterOption(RecordFilter.hasSummary, 'Has Summary', setState),
                  _buildFilterOption(RecordFilter.noSummary, 'No Summary', setState),
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

  Widget _buildFilterOption(RecordFilter filter, String label, StateSetter setState) {
    return RadioListTile<RecordFilter>(
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

  void _showSummaryScreen(HealthRecord record) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => DocumentSummaryScreen(
        record: record,
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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search health records...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                ),
                style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color),
              )
            : const Text('Health Records'),
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
          if (_currentFilter != RecordFilter.all)
            FilterStatusBar(
              filterName: _getFilterDisplayName(_currentFilter),
              onClear: () {
                setState(() {
                  _currentFilter = RecordFilter.all;
                });
              },
            ),
          
          // The StreamBuilder with Expanded to take remaining space
          Expanded(
            child: StreamBuilder<List<HealthRecord>>(
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
                
                // Apply filters
                final allRecords = snapshot.data!;
                final searchFiltered = _filterHealthRecords(allRecords);
                final records = _applyFilters(searchFiltered);
                
                // Show "no results" message when search returns empty
                if (records.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No records match your filters.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _currentFilter = RecordFilter.all;
                            });
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }
                
                // Data available
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
                      onSummarize: () => _showSummaryScreen(record),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}