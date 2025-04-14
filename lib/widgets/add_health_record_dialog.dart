import 'dart:io';
import 'package:flutter/material.dart';
import 'package:healthmate/screens/document_summary_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../models/health_record.dart';
import '../services/health_record_service.dart';

class AddHealthRecordDialog extends StatefulWidget {
  final HealthRecord? recordToEdit;

  const AddHealthRecordDialog({super.key, this.recordToEdit});

  @override
  State<AddHealthRecordDialog> createState() => _AddHealthRecordDialogState();
}

class _AddHealthRecordDialogState extends State<AddHealthRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final HealthRecordService _recordService = HealthRecordService();
  final ImagePicker _picker = ImagePicker();
  
  RecordType _selectedType = RecordType.medicalDocument;
  File? _selectedFile;
  bool _isLoading = false;
  String? _summary;

  @override
  void initState() {
    super.initState();
    if (widget.recordToEdit != null) {
      _titleController.text = widget.recordToEdit!.title;
      _selectedType = widget.recordToEdit!.type;
      _summary = widget.recordToEdit!.summary;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Select document from gallery or camera
  Future<void> _selectDocument() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    
    if (image != null) {
      setState(() => _selectedFile = File(image.path));
    }
  }

  // Capture document using camera
  Future<void> _captureDocument() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    
    if (image != null) {
      setState(() => _selectedFile = File(image.path));
    }
  }

  // Show the AI summarization screen
  Future<void> _showSummarizeScreen() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a document first')),
      );
      return;
    }

    // Create a temporary record object for the summarization screen
    final tempRecord = HealthRecord(
      id: 'temp',
      title: _titleController.text.isNotEmpty ? _titleController.text : 'New Record',
      type: _selectedType,
      url: '',
      dateAdded: DateTime.now(),
      summary: _summary,
    );

    // Show the summary screen and get the result
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentSummaryScreen(
          record: tempRecord,
          isNewRecord: true,
          documentFile: _selectedFile,
        ),
      ),
      );
    
    // Update the summary if we got a result
    if (result != null) {
      setState(() => _summary = result);
    }
  }

  // Save the record
  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Check if we have all required data
    if (_selectedFile == null && widget.recordToEdit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a document file')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      if (widget.recordToEdit == null) {
        // Create new record
        await _recordService.addHealthRecord(
          _titleController.text,
          _selectedType,
          _selectedFile!,
          summary: _summary,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Health record added successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        // Update existing record
        final updatedRecord = widget.recordToEdit!.copyWith(
          title: _titleController.text,
          type: _selectedType,
          summary: _summary,
        );
        
        await _recordService.updateHealthRecord(
          updatedRecord,
          newFile: _selectedFile,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Health record updated successfully')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving record: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recordToEdit != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Health Record' : 'Add Health Record'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Record Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Record type selection
                    const Text(
                      'Record Type',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    
                    // Record type options
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildTypeChip(RecordType.medicalDocument, 'Medical Document'),
                        _buildTypeChip(RecordType.labReport, 'Lab Report'),
                        _buildTypeChip(RecordType.imagingReport, 'Imaging Report'),
                        _buildTypeChip(RecordType.prescription, 'Prescription'),
                        _buildTypeChip(RecordType.medicalNotes, 'Medical Notes'),
                        _buildTypeChip(RecordType.vaccination, 'Vaccination Record'),
                        _buildTypeChip(RecordType.other, 'Other'),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Document selection section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Document',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          
                          // Document preview
                          if (_selectedFile != null)
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedFile!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          else if (isEditing)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Current document will be kept unless you select a new one',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 16),
                          
                          // Document selection buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _captureDocument,
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Camera'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _selectDocument,
                                  icon: const Icon(Icons.image),
                                  label: const Text('Gallery'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // AI Summarization section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'AI Document Summary',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Let AI analyze your document and create a summary of key information.',
                          ),
                          const SizedBox(height: 12),
                          
                          // Display summary if available
                          if (_summary != null && _summary!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Summary:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _summary!,
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          
                          const SizedBox(height: 12),
                          
                          // Summarize button
                          ElevatedButton.icon(
                            onPressed: _showSummarizeScreen,
                            icon: const Icon(Icons.summarize),
                            label: Text(_summary != null && _summary!.isNotEmpty
                                ? 'Edit Summary'
                                : 'Generate AI Summary'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Save button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveRecord,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(isEditing ? 'Update Record' : 'Save Record'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper method to build type selection chips
  Widget _buildTypeChip(RecordType type, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedType == type,
      onSelected: (selected) {
        setState(() => _selectedType = type);
      },
    );
  }
}