import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/health_record.dart';

class DocumentSummarizerService {
  late final GenerativeModel _model;
  
  // Initialize with API key
  DocumentSummarizerService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: apiKey,
    );
  }

  /// Summarizes a health document based on its type and image data
  Future<String> summarizeDocument(RecordType recordType, Uint8List imageBytes) async {
    try {
      // Create prompt based on document type
      final prompt = _createPromptForDocType(recordType);
      
      // Create content parts (both text prompt and image)
      final content = [
        Content.text(prompt),
        Content.multi([
          TextPart(prompt),
          DataPart('image/png', imageBytes),  // or 'image/jpeg' based on your image type
        ]),
      ];

      
      // Generate content
      final response = await _model.generateContent(content);
      
      
      if (response.text == null || response.text!.isEmpty) {
        return "Could not generate summary. Please try again.";
      }
      
      return response.text!;
    } catch (e) {
      return "Error summarizing document: $e";
    }
  }
  
  /// Creates appropriate prompts based on health record type
  String _createPromptForDocType(RecordType recordType) {
    switch (recordType) {
      case RecordType.labReport:
        return 'This is a lab report. Extract and summarize: patient information, test names, results, reference ranges, and any abnormal values. Flag critically abnormal results.';
      case RecordType.prescription:
        return 'This is a prescription. Extract and summarize: patient information, medication names, dosages, frequency, duration, and any special instructions.';
      case RecordType.imagingReport:
        return 'This is an imaging report. Extract and summarize: patient information, imaging type, findings, impressions, and any recommendations.';
      case RecordType.vaccination:
        return 'This is a vaccination record. Extract and summarize: patient information, vaccine name, date administered, lot number, and next dose due date if available.';
      case RecordType.medicalNotes:
        return 'These are medical notes. Extract and summarize key information including: patient details, chief complaints, assessment, plan, and any important follow-up instructions.';
      case RecordType.medicalDocument:
        return 'This is a medical document. Extract and summarize key medical information, including patient details, date, main findings, and any critical information.';
      case RecordType.other:
      default:
        return 'This is a health document. Extract and summarize the key medical information, including patient details, main findings, and any critical information.';
    }
  }
}