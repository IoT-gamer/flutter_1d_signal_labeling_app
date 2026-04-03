import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../models/signal_data.dart';

class ExportService {
  Future<void> exportLabeledData(
    SignalData data,
    String originalFileName,
  ) async {
    // Initialize a mask array with zeros (background class)
    List<int> segmentationMask = List.filled(data.values.length, 0);

    // Overwrite the mask with labeled regions
    for (var region in data.regions) {
      for (int i = region.startIndex; i <= region.endIndex; i++) {
        segmentationMask[i] = region.classId;
      }
    }

    // Prepare CSV rows: [Index, RawValue, ClassId]
    List<List<dynamic>> rows = [
      ["Index", "RawValue", "ClassId"],
    ];

    for (int i = 0; i < data.values.length; i++) {
      rows.add([i, data.values[i], segmentationMask[i]]);
    }

    // Encode using the v8 API with strict newline
    final codec = Csv(lineDelimiter: '\n');
    String csvData = codec.encode(rows);

    // Convert the CSV String into a Byte Array
    List<int> encodedBytes = utf8.encode(csvData);
    Uint8List bytes = Uint8List.fromList(encodedBytes);

    // Prompt the user for exactly where they want to save the file
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Labeled Data',
      fileName: 'labeled_$originalFileName',
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: bytes, // <-- THIS FIXES THE MOBILE ERROR
    );

    // Handle platform-specific writing
    if (outputFile != null) {
      // On Desktop (Windows, macOS, Linux), file_picker simply returns the path,
      // so we still need to write the file manually.
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        if (!outputFile.endsWith('.csv')) {
          outputFile += '.csv';
        }

        final file = File(outputFile);
        await file.writeAsBytes(bytes);
      }
    } else {
      throw Exception("Save operation canceled by user.");
    }
  }
}
