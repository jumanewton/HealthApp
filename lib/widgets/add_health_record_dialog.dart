import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/health_record_service.dart';
import '../models/health_record.dart';

class AddHealthRecordDialog extends StatefulWidget {
  final HealthRecord? recordToEdit;

  const AddHealthRecordDialog({
    super.key,
    this.recordToEdit,
  });

  @override
  _AddHealthRecordDialogState createState() => _AddHealthRecordDialogState();
}

class _AddHealthRecordDialogState extends State<AddHealthRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedType = 'Medical Document';
  File? _selectedFile;
  bool _isUploading = false;
  String? _existingUrl;

  final List<String> _documentTypes = [
    'Medical Document',
    'Lab Report',
    'Imaging Report',
    'Prescription',
    'Medical Notes',
    'Vaccination Record',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // If editing an existing record, populate the form
    if (widget.recordToEdit != null) {
      _titleController.text = widget.recordToEdit!.title;
      _selectedType = widget.recordToEdit!.type;
      _existingUrl = widget.recordToEdit!.url;
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
        print("File selected: ${_selectedFile!.path}");
      } else {
        print("No file selected");
      }
    } catch (e) {
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  Future<void> _uploadRecord() async {
    if (_formKey.currentState!.validate()) {
      // Check if we're updating a record and no new file is selected
      if (widget.recordToEdit != null && _selectedFile == null && _existingUrl != null) {
        // Update only metadata without changing the file
        // This would need a method in your service to update without changing the file
        
        // For now, just show a message that this feature is not implemented
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Updating record metadata without changing the file is not implemented yet.')),
        );
        Navigator.of(context).pop();
        return;
      }
      
      // For new records or when changing the file
      if (_selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a file to upload')),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        final healthRecordService = HealthRecordService();
        await healthRecordService.uploadHealthRecord(
          file: _selectedFile!,
          title: _titleController.text.trim(),
          type: _selectedType,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Record uploaded successfully')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recordToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Health Record' : 'Add Health Record'),
      ),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Uploading your document...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Record Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Document Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _documentTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    if (isEditing && _existingUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Current file: ${_existingUrl!.split('/').last}',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      
                    OutlinedButton.icon(
                      icon: const Icon(Icons.attach_file),
                      label: Text(_selectedFile != null
                          ? 'File selected: ${_selectedFile!.path.split('/').last}'
                          : isEditing 
                              ? 'Select new file (PDF or Word)'
                              : 'Select PDF or Word Document'),
                      onPressed: _pickFile,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _uploadRecord,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(isEditing ? 'Update Record' : 'Upload Record'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}