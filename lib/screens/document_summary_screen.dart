import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/health_record.dart';
import '../services/document_summarizer_service.dart';
import '../services/health_record_service.dart';

class DocumentSummaryScreen extends StatefulWidget {
  final HealthRecord record;
  final bool isNewRecord;
  final File? documentFile;

  const DocumentSummaryScreen({
    super.key,
    required this.record,
    this.isNewRecord = false,
    this.documentFile,
  });

  @override
  State<DocumentSummaryScreen> createState() => _DocumentSummaryScreenState();
}

class _DocumentSummaryScreenState extends State<DocumentSummaryScreen> {
  final DocumentSummarizerService _summarizerService = DocumentSummarizerService();
  final HealthRecordService _recordService = HealthRecordService();
  
  bool _isLoading = false;
  String _summary = '';
  late TextEditingController _summaryController;
  Uint8List? _imageBytes;
  
  @override
  void initState() {
    super.initState();
    _summaryController = TextEditingController(text: widget.record.summary ?? '');
    _summary = widget.record.summary ?? '';
    _loadDocument();
  }
  
  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }
  
  // Load document either from file or URL
  Future<void> _loadDocument() async {
    setState(() => _isLoading = true);
    
    try {
      if (widget.documentFile != null) {
        // Use the provided file
        _imageBytes = await widget.documentFile!.readAsBytes();
      } else if (widget.record.url.isNotEmpty) {
        // Download from URL
        final response = await http.get(Uri.parse(widget.record.url));
        if (response.statusCode == 200) {
          _imageBytes = response.bodyBytes;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading document: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Generate summary using Gemini AI
  Future<void> _generateSummary() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No document available to summarize')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final summary = await _summarizerService.summarizeDocument(
        widget.record.type,
        _imageBytes!,
      );
      
      setState(() {
        _summary = summary;
        _summaryController.text = summary;
      });
      
      // Save the summary if this is an existing record
      if (!widget.isNewRecord) {
        await _recordService.updateRecordSummary(widget.record.id, summary);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating summary: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Save the edited summary
  Future<void> _saveSummary() async {
    if (widget.isNewRecord) {
      // For new records, just return the summary to the add dialog
      Navigator.pop(context, _summaryController.text);
    } else {
      // For existing records, update in database
      setState(() => _isLoading = true);
      
      try {
        await _recordService.updateRecordSummary(
          widget.record.id, 
          _summaryController.text
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Summary saved successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving summary: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveSummary,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Document preview
                if (_imageBytes != null)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _imageBytes!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Generate summary button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateSummary,
                  icon: const Icon(Icons.summarize),
                  label: const Text('Generate AI Summary'),
                ),
                
                const SizedBox(height: 16),
                
                // Summary text field
                TextField(
                  controller: _summaryController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    labelText: 'Summary',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}