import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

import '../models/signal_data.dart';

/// A simple wrapper to return both the parsed data and the original filename
class CsvParseResult {
  final SignalData data;
  final String fileName;

  CsvParseResult({required this.data, required this.fileName});
}

class CsvParserService {
  /// Opens a file picker, reads the selected CSV, and parses a column into SignalData.
  Future<CsvParseResult?> pickAndParseCsv() async {
    try {
      // Prompt the user to pick a CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        // Parse the CSV using the streaming API
        final List<List<dynamic>> csvTable = await file
            .openRead()
            .transform(utf8.decoder)
            .transform(csv.decoder)
            .toList();

        List<double> signalValues = [];

        // Extract the 1D signal
        // Assuming the signal is in the second column (index 1) and row 0 is a header string
        for (int i = 1; i < csvTable.length; i++) {
          if (csvTable[i].isNotEmpty && csvTable[i][1] != null) {
            // Safely parse the value to a double, ignoring malformed rows
            double? val = double.tryParse(csvTable[i][1].toString());
            if (val != null) {
              signalValues.add(val);
            }
          }
        }

        // Return the result if data was successfully parsed
        if (signalValues.isNotEmpty) {
          return CsvParseResult(
            data: SignalData(signalValues),
            fileName: fileName,
          );
        } else {
          throw Exception(
            "The selected CSV file contained no valid numerical data in the first column.",
          );
        }
      }
    } catch (e) {
      // Re-throw the error so the Cubit can catch it and update the UI state
      throw Exception("Failed to parse CSV: $e");
    }

    // Return null if the user simply canceled the file picker dialog
    return null;
  }
}
