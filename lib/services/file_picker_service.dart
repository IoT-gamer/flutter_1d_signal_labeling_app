import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/signal_data.dart';

class FilePickerService {
  Future<SignalData?> loadCsvSignal() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      // Using the new stream transformer approach from the v8 docs
      final List<List<dynamic>> csvTable = await file
          .openRead()
          .transform(utf8.decoder)
          .transform(csv.decoder)
          .toList();

      List<double> signalValues = [];
      // Assuming the signal is in the first column and skipping the header (index 0)
      for (int i = 1; i < csvTable.length; i++) {
        if (csvTable[i].isNotEmpty) {
          signalValues.add(double.parse(csvTable[i][0].toString()));
        }
      }
      return SignalData(signalValues);
    }
    return null;
  }
}
